class AdminController < ApplicationController
  layout "admin"

  before_action :authenticate
  around_action :use_time_zone

  def index
    @total_earnings = Order.paid.sum(:total_price)
    @onhold_earnings = Order.pending.sum(:total_price)
    @total_order = Order.count
    @completed_order = Order.paid.count
    @pending_order = Order.pending.count
    @expired_order = Order.expired.count

    @today_earnings = Order.paid.today.sum(:total_price)
    @today_onhold_earnings = Order.pending.today.sum(:total_price)
    @today_total_order = Order.today.where.not(state: :expired).count
    @today_completed_order = Order.paid.today.count
    @today_pending_order = Order.pending.today.count
    @today_expired_order = Order.expired.today.count

    @products = Product.with_completed_orders.order("total_completed_orders DESC")
  end

  private
    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == Setting.admin_username.value && password == Setting.admin_password.value
      end
    end

    def use_time_zone
      Time.use_zone("Asia/Jakarta") { yield }
    end
end
