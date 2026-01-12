class Transaction::Payment::Midtrans
  attr_reader :payable

  def self.cancel(order_id)
    MidtransClient.new.cancel(order_id)
  end

  def initialize(payable)
    @payable = payable
  end

  def redirect_url
    begin
      self.class.cancel(id)
    rescue MidtransClient::Error => e
      raise StandardError, e if e.message.exclude?("404")
    end

    uuid = SecureRandom.uuid

    if payable.is_a?(Order)
      payable.order_id = uuid
    else
      payable.donation_id = uuid
    end
    payable.save

    MidtransClient.new("snap").snap_redirect_url(payment_url_params)
  end

  def payment_url_params
    payment_params = if payable.is_a?(Order)
      order_payment_url_params
    elsif payable.is_a?(Donation)
      donation_payment_url_params
    else
      raise "Unsupported payable item"
    end
    payment_params[:expiry] = custom_expiry if Rails.env.development?
    payment_params
  end

  def order_payment_url_params
    name_tokens = payable.customer_name.split(" ")
    item_details = payable.line_items.map do |line_item|
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

    if payable.shipping_cost&.positive?
      shipping_name = "Ongkos Kirim"
      shipping_name += " (#{payable.shipping_provider} - #{payable.shipping_method})" if payable.shipping_provider.present? && payable.shipping_method.present?

      item_details << {
        id: "shipping_#{payable.id}",
        name: shipping_name,
        quantity: 1,
        price: payable.shipping_cost,
        brand: "adipurnm",
        category: "Pengiriman",
        merchant_name: "adipurnm"
      }
    end

    {
      transaction_details: {
        order_id: payable.order_id,
        gross_amount: payable.total_price,
        secure: true
      },
      customer_details: {
        first_name: name_tokens.first,
        last_name: name_tokens[1..-1].join(" "),
        email: payable.customer_email_address,
        billing_address: {
          first_name: name_tokens.first,
          last_name: name_tokens[1..-1].join(" "),
          email: payable.customer_email_address
        },
        shipping_address: {
          first_name: name_tokens.first,
          last_name: name_tokens[1..-1].join(" "),
          email: payable.customer_email_address
        }
      },
      item_details: item_details
    }
  end

  def donation_payment_url_params
    name_tokens = payable.name.split(" ")
    {
      transaction_details: {
        order_id: payable.donation_id,
        gross_amount: payable.amount,
        secure: true
      },
      customer_details: {
        first_name: name_tokens.first,
        last_name: name_tokens[1..-1].join(" ")
      },
      item_details: [
        {
          id: payable.id,
          name: payable.name,
          quantity: 1,
          price: payable.amount,
          brand: "adipurnm",
          category: "Donasi",
          merchant_name: "adipurnm"
        }
      ]
    }
  end

  def custom_expiry
    {
      duration: 3,
      unit: "minutes"
    }
  end

  def id
    if payable.is_a? Order
      payable.order_id
    elsif payable.is_a? Donation
      payable.donation_id
    end
  end
end
