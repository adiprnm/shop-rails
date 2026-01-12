class ShippingCostsController < ApplicationController
  def index
    return unless params[:district_id].present?

    district = District.find(params[:district_id])

    cart_total_weight = Current.cart.physical_items.sum do |item|
      variant_weight = item.product_variant&.weight
      base_weight = item.cartable.productable&.weight
      variant_weight || base_weight || 0
    end

    origin_district = District.find(Setting.default_origin_district_id.value)
    return unless origin_district

    origin_type = "District"
    destination_type = "District"

    couriers = Setting.available_couriers.value.to_s.split(",").map(&:strip).reject(&:blank?)
    couriers = [ "jne", "tiki", "pos" ] if couriers.empty?
    included_services = Setting.included_shipping_services.value.to_s.split(",").map(&:strip).reject(&:blank?)

    @shipping_options = []

    couriers.each do |courier|
      cached_costs = ShippingCost.fresh.where(
        origin_type: origin_type,
        origin_id: origin_district.id,
        destination_type: destination_type,
        destination_id: district.id,
        weight: cart_total_weight,
        courier: courier
      )

      if cached_costs.exists?
        cached_costs.each do |shipping_cost|
          service_key = "#{courier}-#{shipping_cost.service}"
          next if included_services.present? && !service_key.in?(included_services)

          @shipping_options << {
            courier: courier.upcase,
            service: shipping_cost.service,
            description: "",
            price: shipping_cost.calculate,
            etd: ""
          }
        end
      else
        response = RajaOngkirClient.new.calculate_cost(
          origin_district.rajaongkir_id,
          district.rajaongkir_id,
          cart_total_weight,
          courier
        )

        next unless response[:success] && response[:data]

        costs_data = response[:data]["data"] || []

        costs_data.each do |cost_data|
          courier_code = cost_data["code"]
          service = cost_data["service"]
          price = cost_data["cost"]
          etd = cost_data["etd"]
          description = cost_data["description"]

          service_key = "#{courier_code}-#{service}"
          next if included_services.present? && !service_key.in?(included_services)

          shipping_cost = ShippingCost.find_or_fetch(
            origin_district,
            district,
            cart_total_weight,
            courier_code,
            service
          ) do
            ShippingCost.new(
              origin_type: origin_type,
              origin_id: origin_district.id,
              destination_type: destination_type,
              destination_id: district.id,
              weight: cart_total_weight,
              courier: courier_code,
              service: service,
              cost: price
            )
          end

          @shipping_options << {
            courier: cost_data["name"],
            service: service,
            description: description,
            price: shipping_cost.calculate,
            etd: etd
          }
        end
      end
    end

    render turbo_stream: turbo_stream.update("shipping-options", partial: "shipping_costs/options", locals: { shipping_options: @shipping_options })
  end
end
