class Setting < ApplicationRecord
  encrypts :value

  has_one_attached :file

  KEYS = %i[
    site_name
    site_favicon
    site_main_menu
    site_storage_host
    site_terms_and_conditions_url
    og_image
    payment_provider
    payment_client_id
    payment_client_secret
    payment_api_host
    payment_qris
    payment_account_name
    payment_account_user_name
    payment_account_number
    email_sender_email
    email_sender_name
    smtp_host
    smtp_port
    smtp_username
    smtp_password
    admin_username
    admin_password
    admin_email
    rajaongkir_api_key
    rajaongkir_api_host
    default_origin_province_id
    default_origin_city_id
    default_origin_district_id
    default_origin_subdistrict_id
  ].freeze
  ATTACHABLE_KEYS = %i[ site_favicon og_image payment_qris ].freeze

  KEYS.each do |key|
    define_singleton_method key do
      find_or_initialize_by(key: key)
    end
  end

  def self.bulk_update(params)
    params.each do |key, value|
      if key.to_sym.in?(ATTACHABLE_KEYS)
        find_or_initialize_by(key: key).update(file: value)
      else
        find_or_initialize_by(key: key).update(value: value)
      end
    end
  end

  def value
    return super unless file.attached?

    Rails.application.routes.url_helpers.rails_blob_url(file, disposition: "inline", only_path: true)
  end
end
