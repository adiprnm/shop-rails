class Transaction
  attr_reader :cart

  def initialize(cart)
    @cart = cart
  end

  def create(params)
    shipping_info = determine_shipping_info(params)
    order_params = build_order_params(params, shipping_info)

    @order = cart.orders.pending.create(order_params)
    return @order if @order.invalid?

    create_order_line_items
    clear_cart
    @order
  end

  private

  def determine_shipping_info(params)
    shipping_cost_obj = ShippingCost.find_by(id: params[:shipping_cost_id])
    shipping_cost_value = if cart.coupon&.free_shipping?
      0
    else
      shipping_cost_obj&.cost || 0
    end

    {
      cost: shipping_cost_value,
      obj: shipping_cost_obj
    }
  end

  def build_order_params(params, shipping_info)
    subtotal = cart.subtotal_price
    coupon_discount = cart.coupon&.calculate_discount(cart) || 0

    base_total = subtotal + shipping_info[:cost]
    final_total = [ base_total - coupon_discount, 0 ].max

    order_params = {
      total_price: final_total,
      shipping_cost: shipping_info[:cost],
      shipping_provider: shipping_info[:obj]&.courier,
      shipping_method: shipping_info[:obj]&.service,
      has_physical_products: cart.contains_physical_product?,
      **params.except(:shipping_cost_id)
    }

    order_params[:shipping_cost_id] = shipping_info[:obj].id if shipping_info[:obj]
    order_params
  end

  def create_order_line_items
    cart.line_items.each do |line_item|
      @order.line_items.create(
        orderable: line_item.cartable,
        orderable_name: line_item.cartable.name,
        orderable_price: line_item.price,
        productable: line_item.cartable.productable,
        product_variant: line_item.product_variant,
        product_variant_name: line_item.product_variant&.name,
        weight: determine_item_weight(line_item)
      )
    end
  end

  def determine_item_weight(line_item)
    if line_item.product_variant
      line_item.product_variant.weight
    elsif line_item.cartable.productable.is_a?(PhysicalProduct)
      line_item.cartable.productable.weight
    end
  end

  def clear_cart
    cart.line_items.delete_all
    cart.update coupon_code: nil
  end
end
