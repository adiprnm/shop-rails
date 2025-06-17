class Transaction::Payment
  attr_reader :order

  def self.cancel(order_id)
    MidtransClient.new.cancel(order_id)
  end

  def initialize(order)
    @order = order
  end

  def payment_url(params = {})
    payment_url_params = payment_url_params(params)

    MidtransClient.new("snap").snap_redirect_url(payment_url_params)
  end

  def payment_url_params(params)
    url = params[:url]
    name_tokens = order.customer_name.split(" ")
    payment_params = {
      transaction_details: {
        order_id: order.order_id,
        gross_amount: order.total_price,
        secure: true
      },
      customer_details: {
        first_name: name_tokens.first,
        last_name: name_tokens[1..-1].join(" "),
        email: order.customer_email_address,
        billing_address: {
          first_name: name_tokens.first,
          last_name: name_tokens[1..-1].join(" "),
          email: order.customer_email_address
        },
        shipping_address: {
          first_name: name_tokens.first,
          last_name: name_tokens[1..-1].join(" "),
          email: order.customer_email_address
        }
      },
      item_details: order.line_items.map do |line_item|
        {
          id: line_item.id,
          name: line_item.orderable_name,
          quantity: 1,
          price: line_item.orderable_price,
          brand: "adipurnm",
          category: line_item.orderable.categories.pluck(:name).join(", ").presence || "Lainnya",
          merchant_name: "adipurnm",
          url: ENV["APP_HOST"].to_s + Rails.application.routes.url_helpers.product_path(line_item.orderable.slug)
        }
      end
    }
    payment_params[:expiry] = custom_expiry if Rails.env.development?
    payment_params
  end

  def custom_expiry
    {
      duration: 3,
      unit: "minutes"
    }
  end
end
