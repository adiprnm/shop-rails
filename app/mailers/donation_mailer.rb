class DonationMailer < ApplicationMailer
  def admin_notification
    admin_email = Setting.admin_email.value
    return if admin_email.blank?

    @donation = params[:donation]

    mail from: from_email,
      to: admin_email,
      subject: "Seseorang telah memberikan donasi!"
  end

  def donor_notification
    @donation = params[:donation]

    mail from: from_email,
      to: @donation.email_address,
      subject: "Donasi kamu berhasil dilakukan!"
  end

  def donation_created
    @donation = params[:donation]

    mail from: from_email,
      to: @donation.email_address,
      subject: "Donasi kamu berhasil dibuat"
  end

  def donate_failed
    @donation = params[:donation]

    mail from: from_email,
      to: @donation.email_address,
      subject: "Donasi kamu belum bisa kami proses"
  end
end
