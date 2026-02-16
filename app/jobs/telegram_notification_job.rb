class TelegramNotificationJob < ApplicationJob
  queue_as :default

  def perform(payable, notification_type)
    @payable = payable

    return unless telegram_configured?

    case notification_type
    when :paid
      send_paid_notification
    when :failed
      send_failed_notification
    when :evidence_uploaded
      send_evidence_uploaded_notification
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "TelegramNotificationJob: Payable not found - #{e.message}"
  rescue StandardError => e
    Rails.logger.error "TelegramNotificationJob: #{e.class} - #{e.message}"
    raise
  end

  private

  attr_reader :payable

  def telegram_configured?
    Current.settings["telegram_enabled"] == "true" &&
      Current.settings["telegram_bot_token"].present? &&
      Current.settings["telegram_chat_id"].present?
  end

  def donation?
    payable.is_a?(Donation)
  end

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

  def send_evidence_uploaded_notification
    evidence = payable.latest_payment_evidence
    return unless evidence&.file&.attached?

    Tempfile.create([ "payment_evidence", File.extname(evidence.file.filename.to_s) ]) do |tempfile|
      tempfile.binmode
      tempfile.write(evidence.file.download)
      tempfile.rewind

      caption = format_evidence_uploaded_message_as_caption
      reply_markup = manual_payment_keyboard
      TelegramClient.new.send_photo(tempfile.path, caption: caption, parse_mode: "Markdown", reply_markup: reply_markup)
    end
  end

  def send_paid_notification_with_photo
    evidence = payable.latest_payment_evidence

    Tempfile.create([ "payment_evidence", File.extname(evidence.file.filename.to_s) ]) do |tempfile|
      tempfile.binmode
      tempfile.write(evidence.file.download)
      tempfile.rewind

      caption = format_paid_message_as_caption
      reply_markup = manual_payment_keyboard
      TelegramClient.new.send_photo(tempfile.path, caption: caption, parse_mode: "Markdown", reply_markup: reply_markup)
    end
  end

  def send_paid_notification_text
    message = format_paid_message
    reply_markup = manual_payment_keyboard
    TelegramClient.new.send_message(message, parse_mode: "Markdown", reply_markup: reply_markup)
  end

  def format_paid_message
    payment_method = Current.settings["payment_provider"].humanize

    if donation?
      format_donation_paid_message(payment_method)
    else
      format_order_paid_message(payment_method)
    end
  end

  def format_order_paid_message(payment_method)
    products = payable.line_items.map { |li| "- #{ li.orderable_name }" }.join("\n")

    <<~MESSAGE
      🔔 *New Order Paid*

      *Order*
      \##{payable.order_id}

      *Customer*
      #{payable.customer_name}

      *Products*
      #{products}

      *Total*
      #{format_currency(payable.total_price)}

      *Payment*
      #{payment_method}

      *Date*
      #{payable.state_updated_at.strftime("%Y-%m-%d %H:%M")}

      #{manual_payment_notice}
    MESSAGE
  end

  def format_donation_paid_message(payment_method)
    <<~MESSAGE
      🔔 *New Donation Paid*

      *Donation*
      \##{payable.donation_id}

      *Donor*
      #{payable.name}

      *Amount*
      #{format_currency(payable.amount)}

      *Message*
      #{payable.message}

      *Payment*
      #{payment_method}

      *Date*
      #{payable.state_updated_at.strftime("%Y-%m-%d %H:%M")}

      #{manual_payment_notice}
    MESSAGE
  end

  def format_paid_message_as_caption
    payment_method = Current.settings["payment_provider"].humanize

    if donation?
      format_donation_paid_message_as_caption(payment_method)
    else
      format_order_paid_message_as_caption(payment_method)
    end
  end

  def format_order_paid_message_as_caption(payment_method)
    products = payable.line_items.map { |li| "- #{ li.orderable_name }" }.join("\n")

    <<~MESSAGE
      🔔 *New Order Paid*

      *Order*
      \##{payable.order_id}

      *Customer*
      #{payable.customer_name}

      *Products*
      #{products}

      *Total*
      #{format_currency(payable.total_price)}

      *Payment*
      #{payment_method}

      *Date*
      #{payable.state_updated_at.strftime("%Y-%m-%d %H:%M")}

      #{manual_payment_notice}
    MESSAGE
  end

  def format_donation_paid_message_as_caption(payment_method)
    <<~MESSAGE
      🔔 *New Donation Paid*

      *Donation*
      \##{payable.donation_id}

      *Donor*
      #{payable.name}

      *Amount*
      #{format_currency(payable.amount)}

      *Message*
      #{payable.message}

      *Payment*
      #{payment_method}

      *Date*
      #{payable.state_updated_at.strftime("%Y-%m-%d %H:%M")}

      #{manual_payment_notice}
    MESSAGE
  end

  def format_evidence_uploaded_message_as_caption
    if donation?
      format_donation_evidence_uploaded_message_as_caption
    else
      format_order_evidence_uploaded_message_as_caption
    end
  end

  def format_order_evidence_uploaded_message_as_caption
    products = payable.line_items.map { |li| "- #{ li.orderable_name }" }.join("\n")

    <<~MESSAGE
      📎 *Payment Evidence Uploaded*

      *Order*
      \##{payable.order_id}

      *Customer*
      #{payable.customer_name}

      *Products*
      #{products}

      *Total*
      #{format_currency(payable.total_price)}

      *Date*
      #{payable.state_updated_at.strftime("%Y-%m-%d %H:%M")}

      ⚠️ *Payment waiting for approval*

      Please review and approve this manual payment.
    MESSAGE
  end

  def format_donation_evidence_uploaded_message_as_caption
    <<~MESSAGE
      📎 *Payment Evidence Uploaded*

      *Donation*

      \##{payable.donation_id}

      *Donor*

      #{payable.name}

      *Amount*

      #{format_currency(payable.amount)}

      *Message*

      #{payable.message}

      *Date*

      #{payable.state_updated_at.strftime("%Y-%m-%d %H:%M")}

      ⚠️ *Payment waiting for approval*

      Please review and approve this manual payment.
    MESSAGE
  end

  def format_failed_message
    if donation?
      format_donation_failed_message
    else
      format_order_failed_message
    end
  end

  def format_order_failed_message
    reason = payable.state == "expired" ? "Payment Expired" : "Payment Failed"

    <<~MESSAGE
      ⚠️ *Order Failed*

      *Order*

      \##{payable.order_id}

      *Customer*

      #{payable.customer_name}

      *Total*

      #{format_currency(payable.total_price)}

      *Reason*

      #{reason}

      *Date*

      #{payable.state_updated_at.strftime("%Y-%m-%d %H:%M")}
    MESSAGE
  end

  def format_donation_failed_message
    reason = payable.state == "expired" ? "Payment Expired" : "Payment Failed"

    <<~MESSAGE
      ⚠️ *Donation Failed*

      *Donation*

      \##{payable.donation_id}

      *Donor*

      #{payable.name}

      *Amount*

      #{format_currency(payable.amount)}

      *Reason*

      #{reason}

      *Date*

      #{payable.state_updated_at.strftime("%Y-%m-%d %H:%M")}
    MESSAGE
  end

  def format_currency(amount)
    "Rp #{amount.to_s.reverse.scan(/.{1,3}/).join(".").reverse}"
  end

  def manual_payment_with_evidence?
    Current.settings["payment_provider"] == "manual" && payable.latest_payment_evidence&.file&.attached?
  end

  def manual_payment_keyboard
    return nil unless Current.settings["payment_provider"] == "manual"

    payable_type = donation? ? "donation" : "order"
    payable_id = donation? ? payable.donation_id : payable.order_id

    {
      inline_keyboard: [
        [
          { text: "✅ Approve", callback_data: "approve:#{payable_type}:#{payable_id}" },
          { text: "❌ Reject", callback_data: "reject:#{payable_type}:#{payable_id}" }
        ]
      ]
    }.to_json
  end

  def manual_payment_notice
    return "" unless Current.settings["payment_provider"] == "manual"

    <<~NOTICE

      ⚠️ *Payment waiting for approval*

      Please review and approve this manual payment.
    NOTICE
  end
end
