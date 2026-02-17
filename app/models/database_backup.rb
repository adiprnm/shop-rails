class DatabaseBackup < ApplicationRecord
  has_one_attached :file, service: Rails.env.production? ? :database_backup : :test
end
