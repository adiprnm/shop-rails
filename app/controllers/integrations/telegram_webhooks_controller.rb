class Integrations::TelegramWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :set_current_cart

  before_action :verify_webhook_secret
  before_action :enforce_https
  before_action :check_rate_limit

  RATE_LIMIT = 30
  RATE_LIMIT_PERIOD = 1.minute

  def create
    update = params[:message]
    callback_query = params[:callback_query]

    if callback_query
      handle_callback_query(callback_query)
    elsif update
      handle_message(update)
    end

    head :ok
  rescue StandardError => e
    Rails.logger.error "Telegram webhook error: #{e.class} - #{e.message}\n#{e.backtrace.first(5).join("\n")}"
    head :ok
  end

  private

  def handle_callback_query(callback_query)
    data = callback_query[:data]
    callback_query_id = callback_query[:id]
    message = callback_query[:message]
    from = callback_query[:from]

    if data.nil? || !data.include?(":")
      TelegramClient.new.answer_callback_query(callback_query_id, text: "Invalid callback data", show_alert: true)
      return
    end

    action, payable_type, payable_id = data.split(":")

    case action
    when "approve"
      approve_payment(payable_type, payable_id, callback_query_id, message)
    when "reject"
      request_rejection_reason(payable_type, payable_id, callback_query_id, message, from)
    when "submit_rejection"
      reject_payment_with_reason(payable_type, payable_id, callback_query_id)
    else
      TelegramClient.new.answer_callback_query(callback_query_id, text: "Unknown action", show_alert: true)
    end
  end

  def handle_message(update)
    text = update[:text]
    user_id = update[:from][:id]

    rejection_key = "pending_rejection:#{user_id}"
    pending = Rails.cache.read(rejection_key)

    if pending && text.present?
      process_rejection_with_reason(pending, text)
      Rails.cache.delete(rejection_key)
    end
  end

  def approve_payment(payable_type, payable_id, callback_query_id, message = nil)
    payable = find_payable(payable_type, payable_id)

    if payable.nil?
      TelegramClient.new.answer_callback_query(callback_query_id, text: "#{payable_type.capitalize} not found", show_alert: true)
      return
    end

    unless payable.pending?
      TelegramClient.new.answer_callback_query(callback_query_id, text: "Payment is not pending", show_alert: true)
      return
    end

    payable.update!(state: "paid")
    payable.mark_evidences_as_checked
    TelegramClient.new.answer_callback_query(callback_query_id, text: "Payment approved successfully!", show_alert: false)
    update_message_status(message, "approved") if message
  end

  def find_payable(payable_type, payable_id)
    case payable_type
    when "order"
      Order.find_by(order_id: payable_id)
    when "donation"
      Donation.find_by(donation_id: payable_id)
    else
      nil
    end
  end

  def request_rejection_reason(payable_type, payable_id, callback_query_id, message, from)
    payable = find_payable(payable_type, payable_id)

    if payable.nil?
      TelegramClient.new.answer_callback_query(callback_query_id, text: "#{payable_type.capitalize} not found", show_alert: true)
      return
    end

    unless payable.pending?
      TelegramClient.new.answer_callback_query(callback_query_id, text: "Payment is not pending", show_alert: true)
      return
    end

    user_id = from[:id]
    chat_id = message[:chat][:id]
    message_id = message[:message_id]
    caption = message[:caption]

    rejection_key = "pending_rejection:#{user_id}"
    cache_data = { payable_type:, payable_id:, chat_id:, message_id:, caption: }

    Rails.cache.write(rejection_key, cache_data, expires_in: 5.minutes)
    TelegramClient.new.send_message_with_reply("Please enter rejection reason:")
  end

  def reject_payment_with_reason(payable_type, payable_id, callback_query_id)
    TelegramClient.new.answer_callback_query(callback_query_id, text: "Please enter the rejection reason in the chat", show_alert: true)
  end

  def process_rejection_with_reason(pending, reason)
    payable_type = pending[:payable_type]
    payable_id = pending[:payable_id]
    chat_id = pending[:chat_id]
    message_id = pending[:message_id]
    caption = pending[:caption]
    caption = remove_payment_waiting_for_approval_text(caption)

    payable = find_payable(payable_type, payable_id)

    if payable.nil?
      Rails.logger.warn "Payment not found during rejection: #{payable_type}:#{payable_id}"
      return
    end

    unless payable.pending?
      Rails.logger.warn "Payment is not pending during rejection: #{payable_type}:#{payable_id}"
      return
    end

    payable.update!(state: "failed", remark: reason)
    payable.mark_evidences_as_checked

    new_caption = [ "❌ *PAYMENT REJECTED*", "", "*Reason:* #{reason}", "", caption ].join("\n")

    TelegramClient.new.edit_message_caption(
      chat_id: chat_id,
      message_id: message_id,
      caption: new_caption
    )

    remove_inline_buttons(chat_id, message_id)
    TelegramClient.new.send_message("✅ Payment rejected successfully!", parse_mode: "Markdown")
  end

  def update_message_status(message, status)
    return unless message

    chat_id = message[:chat][:id]
    message_id = message[:message_id]
    caption = message[:caption]
    caption = remove_payment_waiting_for_approval_text(caption)

    status_text = status == "approved" ? "✅ *PAYMENT APPROVED*" : "❌ *PAYMENT REJECTED*"
    new_caption = [ status_text, "", caption ].join("\n")

    TelegramClient.new.edit_message_caption(
      chat_id: chat_id,
      message_id: message_id,
      caption: new_caption
    )

    remove_inline_buttons(chat_id, message_id)
  end

  def remove_inline_buttons(chat_id, message_id)
    TelegramClient.new.edit_message_reply_markup(
      chat_id: chat_id,
      message_id: message_id
    )
  end

  def remove_payment_waiting_for_approval_text(caption)
    tokens = caption.split("\n")
    index = tokens.find_index { |token| token.include?("Payment waiting for approval") }

    if index
      tokens[0..(index - 1)].join("\n").strip
    else
      caption
    end
  end

  def verify_webhook_secret
    secret_token = Current.settings["telegram_webhook_secret_token"]

    return if secret_token.blank?

    provided_token = request.headers["X-Telegram-Bot-Api-Secret-Token"]

    if provided_token.blank? || provided_token != secret_token
      Rails.logger.warn "Telegram webhook: Invalid or missing secret token"
      head :unauthorized
    end
  end

  def enforce_https
    if !request.local? && request.scheme != "https" && !Rails.env.development?
      head :forbidden
    end
  end

  def check_rate_limit
    return if request.local?

    client_ip = request.headers["CF-Connecting-IP"].presence || request.remote_ip
    rate_key = "telegram_webhook:#{client_ip}"

    current_count = Rails.cache.read(rate_key) || 0

    if current_count >= RATE_LIMIT
      Rails.logger.warn "Telegram webhook rate limit exceeded for #{client_ip}"
      head :too_many_requests
    else
      Rails.cache.write(rate_key, current_count + 1, expires_in: RATE_LIMIT_PERIOD)
    end
  end
end
