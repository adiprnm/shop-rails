class OrderMailer < ApplicationMailer
  before_action :set_order_and_products

  def order_invoice
    site_name = Setting.site_name.value
    mail from: from_email,
      to: @order.customer_email_address,
      subject: "Invoice Pembelian Produk di #{ site_name }"
  end

  def digital_product_accesses
    mail from: from_email,
      to: @order.customer_email_address,
      subject: "Yeay! Pembelian berhasil! Berikut akses untuk produk digitalmu"
  end

  private
    def set_order_and_products
      @order = params[:order]
      @products = params[:products]
    end
end
