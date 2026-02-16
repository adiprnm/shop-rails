class Current < ActiveSupport::CurrentAttributes
  attribute :settings
  attribute :cart
  attribute :time_zone

  def time_zone
    super.presence || "Asia/Jakarta"
  end

  def settings
    current_settings = super.to_h
    return current_settings if current_settings.present?

    Current.settings = Setting.all.with_attached_file.to_a.map { |setting| [ setting.key, setting.value ] }.to_h
  end
end
