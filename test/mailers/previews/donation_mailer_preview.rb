# Preview all emails at http://localhost:3000/rails/mailers/donation_mailer
class DonationMailerPreview < ActionMailer::Preview
  def admin_notification
    donation = Donation.last
    DonationMailer.with(donation: donation).admin_notification
  end
end
