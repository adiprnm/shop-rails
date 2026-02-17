class ShippingCostsController < ApplicationController
  def index
    return unless params[:district_id].present?

    district = District.find(params[:district_id])
    cart_total_weight = calculate_cart_total_weight
    origin_district = District.find(Setting.default_origin_district_id.value)
    return unless origin_district

    couriers = determine_couriers
    included_services = determine_included_services

    @shipping_options = []

    couriers.each do |courier|
      process_courier(origin_district, district, cart_total_weight, courier, included_services)
    end

    render turbo_stream: turbo_stream.update("shipping-options", partial: "shipping_costs/options", locals: { shipping_options: @shipping_options })
  end

  private

  def process_courier(origin_district, destination_district, weight, courier, included_services)
    cached_costs = fetch_cached_costs(origin_district, destination_district, weight, courier)

    if cached_costs.exists?
      process_cached_costs(cached_costs, courier, included_services)
    else
      fetch_and_cache_costs(origin_district, destination_district, weight, courier, included_services)
    end
  end

  def fetch_cached_costs(origin_district, destination_district, weight, courier)
    ShippingCost.fresh.where(
      origin_type: "District",
      origin_id: origin_district.id,
      destination_type: "District",
      destination_id: destination_district.id,
      weight: weight,
      courier: courier
    )
  end

  def process_cached_costs(cached_costs, courier, included_services)
    cached_costs.each do |shipping_cost|
      service_key = "#{courier}-#{shipping_cost.service.downcase}"

      if included_services.blank? || service_key.in?(included_services)
        @shipping_options << build_shipping_option(shipping_cost, courier.upcase, "", "")
      end
    end
  end

  def fetch_and_cache_costs(origin_district, destination_district, weight, courier, included_services)
    response = RajaOngkirClient.new.calculate_cost(
      origin_district.rajaongkir_id,
      destination_district.rajaongkir_id,
      weight,
      courier
    )

    return unless response[:success] && response[:data]

    costs_data = response[:data]["data"] || []

    costs_data.each do |cost_data|
      courier_code = cost_data["code"]
      service = cost_data["service"]
      price = cost_data["cost"]
      etd = cost_data["etd"]
      description = cost_data["description"]

      service_key = "#{courier_code}-#{service.downcase}"

      if included_services.blank? || service_key.in?(included_services)
        shipping_cost = create_or_fetch_shipping_cost(origin_district, destination_district, weight, courier_code, service, price)

        @shipping_options << build_shipping_option(shipping_cost, cost_data["name"], description, etd)
      end
    end
  end

  def create_or_fetch_shipping_cost(origin_district, destination_district, weight, courier_code, service, price)
    ShippingCost.find_or_fetch(
      origin_district,
      destination_district,
      weight,
      courier_code,
      service
    ) do
      ShippingCost.new(
        origin_type: "District",
        origin_id: origin_district.id,
        destination_type: "District",
        destination_id: destination_district.id,
        weight: weight,
        courier: courier_code,
        service: service,
        cost: price
      )
    end
  end

  def build_shipping_option(shipping_cost, courier, description, etd)
    {
      id: shipping_cost.id,
      courier: courier,
      service: shipping_cost.service,
      description: description,
      price: shipping_cost.calculate,
      etd: etd
    }
  end

  def determine_couriers
    Setting.available_couriers.value.to_s.split(",").map(&:strip).reject(&:blank!).presence || [ "jne", "tiki", "pos" ]
  end

  def determine_included_services
    Setting.included_shipping_services.value.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  def calculate_cart_total_weight
    Current.cart.physical_items.sum do |item|
      variant_weight = item.product_variant&.weight
      base_weight = item.cartable.productable&.weight
      variant_weight || base_weight || 0
    end
  end
end
