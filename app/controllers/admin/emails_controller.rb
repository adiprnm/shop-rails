class Admin::EmailsController < ApplicationController
  def test
    DummyMailer.test_email(params[:email_address]).deliver_now
    message = "Email berhasil dikirim! Silahkan cek kotak masuk."
  rescue
    message = "Email gagal dikirim. Silahkan cek kembali alamat atau pengaturan email."
  ensure
    redirect_to admin_emails_path, notice: message
  end
end
