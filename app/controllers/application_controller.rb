class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  before_action :set_settings, :set_current_cart

  private
    def set_settings
      Current.settings = Setting.all.to_a.map { |setting| [ setting.key, setting.value ] }.to_h
    end

    def set_current_cart
      session[:cart_session_id] ||= cart_session_id
      Current.cart = Cart.find_or_create_by(session_id: session[:cart_session_id])
    end

    def cart_session_id
      ip_address = request.headers["CF-Connecting-IP"].presence || request.remote_ip
      Digest::SHA256.hexdigest(ip_address)
    end
end
