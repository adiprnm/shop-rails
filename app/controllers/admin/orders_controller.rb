class Admin::OrdersController < AdminController
  before_action :set_order, only: %w[ show edit update destroy ]

  def index
    all_orders = Order.all.order(created_at: :desc)
    page = (params[:page] || 1).to_i
    @orders, @pagination = Pagination.new(all_orders).paginate(page: page)
  end

  def show; end
  def edit; end
  def update; end

  def destroy
    @order.destroy

    redirect_to admin_orders_path, notice: "Pesanan berhasil dihapus!"
  end

  private
    def set_order
      @order = Order.find(params[:id])
    end
end
