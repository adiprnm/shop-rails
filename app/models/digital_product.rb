class DigitalProduct < ApplicationRecord
  has_one_attached :resource
  has_one :product, as: :productable, dependent: :destroy

  enum :resource_type, %w[ file url ]

  def resource_path(only_path: true)
    return url if url?
    return unless resource.attached?

    options = {}
    options[:only_path] = true if only_path
    Rails.application.routes.url_helpers.rails_blob_url(resource, **options)
  end
end
