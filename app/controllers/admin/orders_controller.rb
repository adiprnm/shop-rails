class Admin::OrdersController < ApplicationController
  layout "admin"

  before_action :set_order, only: %w[ show edit update destroy ]

  def index
    @orders = Order.all.order(id: :desc)
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
