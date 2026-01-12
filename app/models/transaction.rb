class Transaction
  attr_reader :cart

  def initialize(cart)
    @cart = cart
  end

  def create(params)
    shipping_cost_obj = ShippingCost.find_by(id: params[:shipping_cost_id])
    shipping_cost_value = shipping_cost_obj&.cost || 0

    order_params = {
      total_price: cart.total_price + shipping_cost_value,
      shipping_cost: shipping_cost_value,
      shipping_provider: shipping_cost_obj&.courier,
      shipping_method: shipping_cost_obj&.service,
      has_physical_products: cart.contains_physical_product?,
      **params.except(:shipping_cost_id)
    }

    order_params[:shipping_cost_id] = shipping_cost_obj.id if shipping_cost_obj

    @order = cart.orders.pending.create(order_params)
    return @order if @order.invalid?

    cart.line_items.each do |line_item|
      weight = if line_item.product_variant
                 line_item.product_variant.weight
      elsif line_item.cartable.productable.is_a?(PhysicalProduct)
                 line_item.cartable.productable.weight
      end

      @order.line_items.create(
        orderable: line_item.cartable,
        orderable_name: line_item.cartable.name,
        orderable_price: line_item.price,
        productable: line_item.cartable.productable,
        product_variant: line_item.product_variant,
        product_variant_name: line_item.product_variant&.name,
        weight: weight,
      )
    end
    cart.line_items.delete_all
    @order
  end
end
