class Order::Notification
  attr_reader :order, :line_items

  def self.with(order:)
    new(order)
  end

  def initialize(order)
    @order = order
    @line_items = order.line_items.to_a
  end

  def notify
    notify_admin if Current.settings["payment_provider"] == "midtrans"
    notify_customer
    notify_telegram_admin
  end

  def notify_created
    OrderMailer.with(order: order, products: line_items).order_created.deliver_later
  end

  def notify_failed
    OrderMailer.with(order: order, products: line_items).order_failed.deliver_later
    notify_telegram_failed
  end

  def notify_tracking_number
    OrderMailer.with(order: order, products: line_items).shipping_tracking.deliver_later
  end

  def notify_admin
    OrderMailer
      .with(order: order, products: line_items)
      .admin_notification
      .deliver_later
  end

  def notify_customer
    OrderMailer.with(order: order, products: line_items).order_invoice.deliver_later

    digital_products = line_items.select(&:digital_product?)
    if digital_products.present?
      OrderMailer.with(order: order, products: digital_products).digital_product_accesses.deliver_later
    end
  end

  def notify_telegram_admin
    return unless telegram_enabled?

    TelegramNotificationJob.perform_later(order.id, :paid)
  end

  def notify_telegram_failed
    return unless telegram_enabled?

    TelegramNotificationJob.perform_later(order.id, :failed)
  end

  private
    def telegram_enabled?
      Current.settings["telegram_enabled"] &&
        Current.settings["telegram_enabled"] == "true" &&
        Current.settings["telegram_bot_token"].present? &&
        Current.settings["telegram_chat_id"].present?
    end
end
