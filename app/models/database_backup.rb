class DatabaseBackup < ApplicationRecord
  has_one_attached :file, service: Rails.env.production? ? :r2 : :test
end
