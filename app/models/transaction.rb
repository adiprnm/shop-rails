class Transaction
  attr_reader :cart

  def initialize(cart)
    @cart = cart
  end

  def create(params)
    @order = cart.orders.pending.create(
      total_price: cart.total_price,
      has_physical_products: cart.contains_physical_product?,
      **params,
    )
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
        weight: weight,
      )
    end
    cart.line_items.delete_all
    @order
  end
end
