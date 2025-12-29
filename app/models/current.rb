class Current < ActiveSupport::CurrentAttributes
  attribute :settings
  attribute :cart
  attribute :time_zone

  def time_zone
    super.presence || "Asia/Jakarta"
  end
end
