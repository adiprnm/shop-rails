class Integrations::TelegramWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

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
    Rails.logger.error "Telegram webhook error: #{e.class} - #{e.message}"
    head :ok
  end

  private

  def handle_callback_query(callback_query)
    data = callback_query[:data]
    callback_query_id = callback_query[:id]

    unless data&.include?(":")
      TelegramClient.new.answer_callback_query(callback_query_id, text: "Invalid callback data", show_alert: true)
      return
    end

    action, payable_type, payable_id = data.split(":")

    case action
    when "approve"
      approve_payment(payable_type, payable_id, callback_query_id)
    when "reject"
      reject_payment(payable_type, payable_id, callback_query_id)
    else
      TelegramClient.new.answer_callback_query(callback_query_id, text: "Unknown action", show_alert: true)
    end
  end

  def handle_message(update)
    Rails.logger.info "Telegram message received: #{update[:text]}"
  end

  def approve_payment(payable_type, payable_id, callback_query_id)
    payable = find_payable(payable_type, payable_id)

    unless payable
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
  end

  def reject_payment(payable_type, payable_id, callback_query_id)
    payable = find_payable(payable_type, payable_id)

    unless payable
      TelegramClient.new.answer_callback_query(callback_query_id, text: "#{payable_type.capitalize} not found", show_alert: true)
      return
    end

    unless payable.pending?
      TelegramClient.new.answer_callback_query(callback_query_id, text: "Payment is not pending", show_alert: true)
      return
    end

    payable.update!(state: "failed")
    payable.mark_evidences_as_checked
    TelegramClient.new.answer_callback_query(callback_query_id, text: "Payment rejected", show_alert: false)
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
end
