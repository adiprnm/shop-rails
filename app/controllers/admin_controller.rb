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

    @total_coupons = Coupon.count
    @active_coupons = Coupon.active.count
    @total_coupon_usage = CouponUsage.count
    @total_discount_given = CouponUsage.sum(:discount_amount)

    @today_created_coupons = Coupon.today.count
    @today_activated_coupons = 0
    @today_coupon_usage = CouponUsage.joins(:order).where(orders: { created_at: Time.current.all_day }).count
    @today_discount_given = CouponUsage.joins(:order).where(orders: { created_at: Time.current.all_day }).sum(:discount_amount)

    @revenue_chart_data = revenue_chart_data
    @order_trend_data = order_trend_data
    @category_sales_data = category_sales_data
    @top_products = top_products
    @average_order_value = average_order_value
    @repeat_customers = repeat_customers_count
    @geographic_distribution = geographic_distribution
    @coupon_effectiveness = coupon_effectiveness_data
      @coupon_usage_chart_data = coupon_usage_chart_data
      @top_coupons = top_coupons_data
    end

    def export_coupons
      @coupons = Coupon.all.order(created_at: :desc)

      respond_to do |format|
        format.csv do
          send_data generate_coupons_csv(@coupons), filename: "coupons_#{Date.current}.csv", type: "text/csv"
        end
      end
    end

    def coupon_usage_report
    @coupon_usages = CouponUsage.includes(:coupon, :order).order(created_at: :desc)

    @coupon_code = params[:coupon_code]
    @coupon_usages = @coupon_usages.where(coupons: { code: @coupon_code }) if @coupon_code.present?

    @date_from = params[:date_from]
    @date_to = params[:date_to]
    if @date_from.present? && @date_to.present?
      @coupon_usages = @coupon_usages.where(orders: { created_at: @date_from.to_date..@date_to.to_date })
    end

    respond_to do |format|
      format.html
      format.csv do
        send_data generate_coupon_usage_csv(@coupon_usages), filename: "coupon_usage_#{Date.current}.csv", type: "text/csv"
      end
    end
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

    def generate_coupon_usage_csv(coupon_usages)
      require "csv"

      CSV.generate(headers: true) do |csv|
        csv << [ "ID", "Kode Kupon", "Tipe Diskon", "Jumlah Diskon", "ID Pesanan", "Email Pelanggan", "Tanggal Penggunaan" ]

        coupon_usages.find_each(batch_size: 1000) do |usage|
          csv << [
            usage.id,
            usage.coupon.code,
            usage.coupon.discount_type.humanize,
            idr(usage.discount_amount),
            usage.order.order_id,
            usage.order.customer_email_address,
            usage.created_at.to_s(:long)
          ]
        end
      end
    end

    def generate_coupons_csv(coupons)
      require "csv"

      CSV.generate(headers: true) do |csv|
        csv << [ "ID", "Kode", "Deskripsi", "Tipe Diskon", "Jumlah Diskon", "Status", "Limit Penggunaan", "Total Limit", "Tanggal Dibuat", "Berlaku Dari", "Berlaku Hingga", "Jumlah Digunakan" ]

        coupons.each do |coupon|
          csv << [
            coupon.id,
            coupon.code,
            coupon.description || "-",
            coupon.discount_type.humanize,
            coupon.discount_amount,
            coupon.state.humanize,
            coupon.usage_limit_per_user,
            coupon.usage_limit,
            coupon.created_at.to_s(:long),
            coupon.starts_at&.to_s(:long) || "-",
            coupon.expires_at&.to_s(:long) || "-",
            coupon.usage_count
          ]
        end
      end
    end

    def coupon_usage_chart_data
      last_30_days = 30.days.ago.to_date..Date.current

      usage_by_date = CouponUsage.joins(:order, :coupon)
        .where(orders: { created_at: last_30_days })
        .group("DATE(orders.created_at)")
        .group("coupons.code")
        .select("DATE(orders.created_at) as date, coupons.code as code, COUNT(*) as count")
        .order("date ASC")
        .to_a

      dates = usage_by_date.map { |u| u[:date].to_s }.uniq.sort
      coupons = Coupon.active.order(created_at: :desc).limit(10).pluck(:code)

      {
        dates: dates,
        coupons: coupons,
        data: coupons.map do |coupon_code|
          coupon_data = usage_by_date.select { |u| u[:code] == coupon_code }
          dates.map do |date|
            record = coupon_data.find { |u| u[:date].to_s == date }
            record&.fetch(:count, 0) || 0
          end
        end
      }
    end

    def top_coupons_data
      CouponUsage.joins(:coupon, :order)
        .where(orders: { state: :paid })
        .group("coupons.id, coupons.code, coupons.discount_type")
        .select("coupons.id, coupons.code, coupons.discount_type, COUNT(*) as usage_count, SUM(coupon_usages.discount_amount) as total_discount")
        .order("usage_count DESC")
        .limit(10)
        .to_a
    end
end
