class ShippingCostsController < ApplicationController
  def index
    return unless params[:subdistrict_id].present?

    subdistrict = Subdistrict.find(params[:subdistrict_id])

    cart_total_weight = Current.cart.physical_items.sum do |item|
      variant_weight = item.product_variant&.weight
      base_weight = item.cartable.productable&.weight
      variant_weight || base_weight || 0
    end

    origin_district = District.first
    return unless origin_district

    origin_type = "District"
    destination_type = "Subdistrict"

    couriers = [ "jne", "tiki", "pos" ]
    @shipping_options = []

    couriers.each do |courier|
      response = RajaOngkirClient.new.calculate_cost(
        origin_district.rajaongkir_id,
        subdistrict.rajaongkir_id,
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

        shipping_cost = ShippingCost.find_or_fetch(
          origin_district,
          subdistrict,
          cart_total_weight,
          courier_code,
          service
        ) do
          ShippingCost.new(
            origin_type: origin_type,
            origin_id: origin_district.id,
            destination_type: destination_type,
            destination_id: subdistrict.id,
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

    render turbo_stream: turbo_stream.update("shipping-options", partial: "shipping_costs/options", locals: { shipping_options: @shipping_options })
  end
end
