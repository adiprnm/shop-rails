class TelegramNotificationJob < ApplicationJob
  queue_as :default

  def perform(order_id, notification_type)
    @order = Order.find(order_id)

    case notification_type
    when :paid
      send_paid_notification
    when :failed
      send_failed_notification
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "TelegramNotificationJob: Order not found - #{e.message}"
  rescue StandardError => e
    Rails.logger.error "TelegramNotificationJob: #{e.class} - #{e.message}"
    raise
  end

  private

  attr_reader :order

  def send_paid_notification
    if manual_payment_with_evidence?
      send_paid_notification_with_photo
    else
      send_paid_notification_text
    end
  end

  def send_failed_notification
    message = format_failed_message
    TelegramClient.new.send_message(message, parse_mode: "Markdown")
  end

  def send_paid_notification_with_photo
    evidence = order.latest_payment_evidence

    Tempfile.create(["payment_evidence", File.extname(evidence.file.filename.to_s)]) do |tempfile|
      tempfile.binmode
      tempfile.write(evidence.file.download)
      tempfile.rewind

      caption = format_paid_message_as_caption
      TelegramClient.new.send_photo(tempfile.path, caption: caption, parse_mode: "Markdown")
    end
  end

  def send_paid_notification_text
    message = format_paid_message
    TelegramClient.new.send_message(message, parse_mode: "Markdown")
  end

  def format_paid_message
    products = order.line_items.map { |li| li.orderable_name }.join(", ")
    payment_method = Current.settings["payment_provider"].humanize

    <<~MESSAGE
      🔔 *New Order Paid*

      Order: \##{order.order_id}
      Customer: #{order.customer_name}
      Products: #{products}
      Total: #{format_currency(order.total_price)}
      Payment: #{payment_method}
      Date: #{order.state_updated_at.strftime("%Y-%m-%d %H:%M")}
    MESSAGE
  end

  def format_paid_message_as_caption
    products = order.line_items.map { |li| li.orderable_name }.join(", ")
    payment_method = Current.settings["payment_provider"].humanize

    <<~MESSAGE
      🔔 *New Order Paid*

      Order: \##{order.order_id}
      Customer: #{order.customer_name}
      Products: #{products}
      Total: #{format_currency(order.total_price)}
      Payment: #{payment_method}
      Date: #{order.state_updated_at.strftime("%Y-%m-%d %H:%M")}
    MESSAGE
  end

  def format_failed_message
    reason = order.state == "expired" ? "Payment Expired" : "Payment Failed"

    <<~MESSAGE
      ⚠️ *Order Failed*

      Order: \##{order.order_id}
      Customer: #{order.customer_name}
      Total: #{format_currency(order.total_price)}
      Reason: #{reason}
      Date: #{order.state_updated_at.strftime("%Y-%m-%d %H:%M")}
    MESSAGE
  end

  def format_currency(amount)
    "Rp #{amount.to_s.reverse.scan(/.{1,3}/).join(".").reverse}"
  end

  def manual_payment_with_evidence?
    Current.settings["payment_provider"] == "manual" && order.latest_payment_evidence&.file&.attached?
  end
end
