class DatabaseBackupJob < ApplicationJob
  MAX_BACKUP_FILE = 3

  queue_as :default

  def perform
    backup = create_new_backup
    remove_old_backup
    backup
  end

  private
    def create_new_backup
      backup = DatabaseBackup.create!
      backup.file.attach(
        io: database_file.open,
        filename: file_name,
        content_type: "application/x-sqlite3"
      )
      backup
    end

    # We assumed multiple database setup
    # to separate database for background jobs.
    # returns <Pathname:~/primary_development.sqlite3>
    def database_file
      Rails.root.join database_file_for(:primary)
    end

    def file_name
      "#{Time.now.strftime("%Y-%m-%d")}-#{database_file.basename}"
    end

    def database_file_for(database_name)
      Rails.application.config_for(:database).dig database_name, :database
    end

    # Retain only last MAX_BACKUP_FILE days of backups
    def remove_old_backup
      if DatabaseBackup.all.count > MAX_BACKUP_FILE
        old_backup = DatabaseBackup.order(:created_at).first
        old_backup.file.purge_later
        old_backup.destroy
      end
    end
end
