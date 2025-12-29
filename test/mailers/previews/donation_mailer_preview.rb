# Preview all emails at http://localhost:3000/rails/mailers/donation_mailer
class DonationMailerPreview < ActionMailer::Preview
  def admin_notification
    donation = Donation.last
    DonationMailer.with(donation: donation).admin_notification
  end

  def donate_failed
    donation = Donation.last || Donation.new(created_at: Time.now, amount: 50_000_000, donation_id: SecureRandom.uuid)
    donation.remark = "Testing ajah"
    DonationMailer.with(donation: donation).donate_failed
  end

  def donation_created
    donation = Donation.last
    DonationMailer.with(donation: donation).donation_created
  end

  def donor_notification
    donation = Donation.last || Donation.new(created_at: Time.now, amount: 50_000_000, donation_id: SecureRandom.uuid)
    DonationMailer.with(donation: donation).donor_notification
  end
end
