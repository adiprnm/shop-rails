class ApplicationMailer < ActionMailer::Base
  helper ApplicationHelper

  default from: email_address_with_name("noreply@adipurnm.my.id", "Adi Purnama")
  layout "mailer"

  before_deliver :set_settings

  def mail(params)
    super params.merge(delivery_method_options)
  end

  private
    def set_settings
      Current.settings = Setting.all.to_a.map { |setting| [ setting.key, setting.value ] }.to_h
    end

    def from_email
      if Rails.env.development?
        email_address_with_name("noreply@adipurnm.my.id", "Adi Purnama")
      else
        Setting.email_sender_email.value
      end
    end

    def delivery_method_options
      if Rails.env.development?
        {}
      else
        settings = Setting.where(key: [ "smtp_host", "smtp_port", "smtp_username", "smtp_password" ])
                          .map { |setting| [ setting.key, setting.value ] }.to_h
        {
          delivery_method_options: {
            address:         settings["smtp_host"],
            port:            settings["smtp_port"].to_i,
            authentication:  "plain",
            user_name:       settings["smtp_username"],
            password:        settings["smtp_password"]
          }
        }
      end
    end
end
