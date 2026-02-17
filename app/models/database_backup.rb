class DatabaseBackup < ApplicationRecord
  has_one_attached :file
end
