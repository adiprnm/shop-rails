class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  before_action :set_settings

  private
    def set_settings
      Current.settings = Setting.all.pluck(:key, :value).to_h
    end
end
