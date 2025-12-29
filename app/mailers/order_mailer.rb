class OrderMailer < ApplicationMailer
  before_action :set_order_and_products

  def order_invoice
    site_name = Setting.site_name.value
    mail from: from_email,
      to: @order.customer_email_address,
      subject: "Invoice Pembelian Produk di #{ site_name }"
  end

  def admin_notification
    admin_email = Setting.admin_email.value
    return if admin_email.blank?

    mail from: from_email,
      to: admin_email,
      subject: "Seseorang membeli produk kita!"
  end

  def order_created
    mail from: from_email,
      to: @order.customer_email_address,
      subject: "Order berhasil dibuat!"
  end

  def order_failed
    mail from: from_email,
      to: @order.customer_email_address,
      subject: "Order kamu belum bisa kami proses"
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
