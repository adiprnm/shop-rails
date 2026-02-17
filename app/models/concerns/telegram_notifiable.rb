module TelegramNotifiable
  extend ActiveSupport::Concern

  private

  def telegram_enabled?
    Current.settings["telegram_enabled"] &&
      Current.settings["telegram_enabled"] == "true" &&
      Current.settings["telegram_bot_token"].present? &&
      Current.settings["telegram_chat_id"].present?
  end
end
