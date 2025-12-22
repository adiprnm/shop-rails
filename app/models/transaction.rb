class Transaction
  attr_reader :cart

  def initialize(cart)
    @cart = cart
  end

  def create(params)
    @order = cart.orders.pending.create(
      total_price: cart.total_price,
      **params,
    )
    return @order if @order.invalid?

    cart.line_items.each do |line_item|
      @order.line_items.create(
        orderable: line_item.cartable,
        orderable_name: line_item.cartable.name,
        orderable_price: line_item.price,
        productable: line_item.cartable.productable,
      )
    end
    cart.line_items.delete_all
    @order
  end
end
