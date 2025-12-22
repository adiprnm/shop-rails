class DonationMailer < ApplicationMailer
  def admin_notification
    admin_email = Setting.admin_email.value
    return if admin_email.blank?

    @donation = params[:donation]

    mail from: from_email,
      to: admin_email,
      subject: "Seseorang telah memberikan donasi!"
  end
end
