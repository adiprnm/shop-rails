class DummyMailer < ApplicationMailer
  def test_email(email_address)
    @email_address = email_address

    mail from: from_email, to: email_address, subject: "Ini adalah email test"
  end
end
