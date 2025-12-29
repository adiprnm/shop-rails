class Admin::OrdersController < AdminController
  before_action :set_order, only: %w[ show edit update destroy ]

  def index
    all_orders = Order.all.order(created_at: :desc)
    if params[:product_id].present?
      all_orders = all_orders.joins(:line_items).merge(OrderLineItem.where(orderable_id: params[:product_id]))
    end

    if params[:state].present?
      all_orders = all_orders.where(state: params[:state])
    end

    page = (params[:page] || 1).to_i
    @orders, @pagination = Pagination.new(all_orders).paginate(page: page)
  end

  def show; end
  def edit; end

  def update
    @order.update(
      params
      .require(:order)
      .permit(
        :customer_name,
        :customer_email_address,
        :customer_agree_to_terms,
        :customer_agree_to_receive_newsletter,
        :state,
        :remark,
      )
    )

    if @order.saved_change_to_state?
      @order.mark_evidences_as_checked
    end

    redirect_to admin_order_path(@order)
  end

  def destroy
    @order.destroy

    redirect_to admin_orders_path, notice: "Pesanan berhasil dihapus!"
  end

  private
    def set_order
      @order = Order.find(params[:id])
    end
end
