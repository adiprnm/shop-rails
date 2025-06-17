# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  def order_invoice
    order = Order.last
    products = order.line_items
    OrderMailer.with(order: order, products: products).order_invoice
  end

  def digital_product_accesses
    order = Order.last
    products = order.line_items.where(productable_type: "DigitalProduct")
    OrderMailer.with(order: order, products: products).digital_product_accesses
  end
end
