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
    cart.line_items.each do |line_item|
      @order.line_items.create(
        cartable: line_item.cartable,
        cartable_name: line_item.cartable.name,
        cartable_price: line_item.cartable.actual_price
      )
    end
    cart.line_items.delete_all
    @order
  end
end
