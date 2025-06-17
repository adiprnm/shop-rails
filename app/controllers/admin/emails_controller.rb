class Admin::EmailsController < AdminController
  def test
    DummyMailer.test_email(params[:email_address]).deliver_now
    message = { notice: "Email berhasil dikirim! Silahkan cek kotak masuk." }
  rescue => e
    message = { alert: "Email gagal dikirim. Silahkan cek kembali alamat atau pengaturan email. Pesan: #{ e.message }" }
  ensure
    redirect_to admin_emails_path, **message
  end
end
