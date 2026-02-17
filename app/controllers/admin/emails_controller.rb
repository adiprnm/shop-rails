class Admin::EmailsController < AdminController
  def test
    DummyMailer.test_email(params[:email_address]).deliver_now
    redirect_to admin_emails_path, notice: success_message
  rescue => e
    redirect_to admin_emails_path, alert: error_message(e)
  end

  private

  def success_message
    "Email berhasil dikirim! Silahkan cek kotak masuk."
  end

  def error_message(error)
    "Email gagal dikirim. Silahkan cek kembali alamat atau pengaturan email. Pesan: #{error.message}"
  end
end
