class ShippingCostsController < ApplicationController
  def index
    return unless params[:subdistrict_id].present?

    subdistrict = Subdistrict.find(params[:subdistrict_id])
    destination = subdistrict

    cart_total_weight = Current.cart.physical_items.sum do |item|
      variant_weight = item.product_variant&.weight
      base_weight = item.cartable.productable&.weight
      variant_weight || base_weight || 0
    end

    origin = Province.first
    origin_type = "province"

    couriers = [ "jne", "tiki", "pos" ]
    @shipping_options = []

    couriers.each do |courier|
      response = RajaOngkirClient.new.calculate_cost(
        origin,
        destination,
        cart_total_weight,
        courier
      )

      next unless response[:success] && response[:data]

      costs_data = response[:data]["rajaongkir"]["results"][0]["costs"] || []

      costs_data.each do |cost_data|
        service = cost_data["service"]
        price = cost_data["cost"][0]["value"]
        etd = cost_data["cost"][0]["etd"]

        shipping_cost = ShippingCost.find_or_fetch(
          origin,
          destination,
          cart_total_weight,
          courier,
          service
        ) do
          ShippingCost.new(
            origin_type: origin_type,
            origin_id: origin.id,
            destination_type: "Subdistrict",
            destination_id: destination.id,
            weight: cart_total_weight,
            courier: courier,
            service: service,
            cost: price
          )
        end

        @shipping_options << {
          courier: courier.upcase,
          service: service,
          price: shipping_cost.calculate,
          etd: etd
        }
      end
    end

    render turbo_stream: turbo_stream.update("shipping-options", partial: "shipping_costs/options", locals: { shipping_options: @shipping_options })
  end
end
