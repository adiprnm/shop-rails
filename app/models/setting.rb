class Setting < ApplicationRecord
  encrypts :value

  has_one_attached :file

  def self.bulk_update(params)
    params.each do |key, value|
      if key.to_s == "og_image"
        find_or_initialize_by(key: key).update(file: value)
      else
        find_or_initialize_by(key: key).update(value: value)
      end
    end
  end

  def value
    super || Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true)
  end
end
