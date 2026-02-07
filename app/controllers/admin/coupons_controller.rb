class Admin::CouponsController < AdminController
  before_action :set_coupon, only: %i[edit update destroy activate deactivate]
  before_action :set_products_and_categories, only: %i[new edit]

  def index
    @coupons = Coupon.order(created_at: :desc)
    @coupons = @coupons.where(state: params[:state]) if params[:state].present?
    @coupons = @coupons.where("code LIKE ?", "%#{params[:search]}%") if params[:search].present?
  end

  def show
    @coupon_usages = @coupon.coupon_usages.includes(:order).order(created_at: :desc)
  end

  def new
    @coupon = Coupon.new
  end

  def create
    @coupon = Coupon.new(coupon_params)

    ActiveRecord::Base.transaction do
      @coupon.save!

      process_restrictions(@coupon)
    end

    redirect_to admin_coupons_path, notice: "Coupon created successfully"
  rescue ActiveRecord::RecordInvalid
    set_products_and_categories
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    ActiveRecord::Base.transaction do
      @coupon.update!(coupon_params)

      @coupon.coupon_restrictions.destroy_all
      process_restrictions(@coupon)
    end

    redirect_to admin_coupons_path, notice: "Coupon updated successfully"
  rescue ActiveRecord::RecordInvalid
    set_products_and_categories
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @coupon.destroy!
    redirect_to admin_coupons_path, notice: "Coupon deleted successfully"
  end

  def activate
    @coupon.update!(state: "active")
    redirect_to admin_coupons_path, notice: "Coupon activated"
  end

  def deactivate
    @coupon.update!(state: "inactive")
    redirect_to admin_coupons_path, notice: "Coupon deactivated"
  end

  private

  def set_coupon
    @coupon = Coupon.find(params[:id])
  end

  def set_products_and_categories
    @products = Product.active
    @categories = Category.all
  end

  def coupon_params
    params.require(:coupon).permit(
      :code, :description, :discount_type, :discount_amount,
      :starts_at, :expires_at,
      :minimum_amount, :maximum_amount,
      :usage_limit, :usage_limit_per_user,
      :exclude_sale_items, :state
    )
  end

  def process_restrictions(coupon)
    if params[:coupon][:included_product_ids].present?
      params[:coupon][:included_product_ids].each do |product_id|
        next if product_id.blank?
        coupon.coupon_restrictions.create!(
          restriction_type: "Product",
          restriction_id: product_id,
          restriction_kind: "include"
        )
      end
    end

    if params[:coupon][:excluded_product_ids].present?
      params[:coupon][:excluded_product_ids].each do |product_id|
        next if product_id.blank?
        coupon.coupon_restrictions.create!(
          restriction_type: "Product",
          restriction_id: product_id,
          restriction_kind: "exclude"
        )
      end
    end

    if params[:coupon][:included_category_ids].present?
      params[:coupon][:included_category_ids].each do |category_id|
        next if category_id.blank?
        coupon.coupon_restrictions.create!(
          restriction_type: "Category",
          restriction_id: category_id,
          restriction_kind: "include"
        )
      end
    end

    if params[:coupon][:excluded_category_ids].present?
      params[:coupon][:excluded_category_ids].each do |category_id|
        next if category_id.blank?
        coupon.coupon_restrictions.create!(
          restriction_type: "Category",
          restriction_id: category_id,
          restriction_kind: "exclude"
        )
      end
    end
  end
end
