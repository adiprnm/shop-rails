require "test_helper"
require "mocha/minitest"

class DatabaseBackupJobTest < ActiveJob::TestCase
  setup do
    @job = DatabaseBackupJob.new
    @database_file = Tempfile.new([ "test_db", ".sqlite3" ])
    @database_file.write("test database content")
    @database_file.rewind
    @database_path = Pathname.new(@database_file.path)
  end

  teardown do
    @database_file.close
    File.unlink(@database_file.path) if File.exist?(@database_file.path)
  end

  test "creates a new database backup" do
    @job.stubs(:database_file).returns(@database_path)

    assert_difference "DatabaseBackup.count", 1 do
      @job.perform
    end
  end

  test "attaches database file to backup" do
    @job.stubs(:database_file).returns(@database_path)

    backup = @job.perform
    assert backup.file.attached?
    assert_match(/\.sqlite3$/, backup.file.filename.to_s)
  end

  test "keeps maximum of 3 backups" do
    4.times do |i|
      backup = DatabaseBackup.create!
      backup.file.attach(
        io: StringIO.new("test content #{i}"),
        filename: "backup_#{i}.sql",
        content_type: "application/x-sqlite3"
      )
    end

    assert_difference "DatabaseBackup.count", -1 do
      @job.send(:remove_old_backup)
    end
  end

  test "removes oldest backup when exceeding max limit" do
    DatabaseBackup.delete_all
    4.times do |i|
      backup = DatabaseBackup.create!(created_at: i.days.ago)
      backup.file.attach(
        io: StringIO.new("test content #{i}"),
        filename: "backup_#{i}.sql",
        content_type: "application/x-sqlite3"
      )
    end

    assert_equal 4, DatabaseBackup.count

    oldest_backup = DatabaseBackup.order(:created_at).first

    @job.send(:remove_old_backup)

    assert_not DatabaseBackup.exists?(oldest_backup.id)
    assert_equal 3, DatabaseBackup.count
  end

  test "does not remove backups when under max limit" do
    DatabaseBackup.delete_all
    2.times do |i|
      backup = DatabaseBackup.create!
      backup.file.attach(
        io: StringIO.new("test content #{i}"),
        filename: "backup_#{i}.sql",
        content_type: "application/x-sqlite3"
      )
    end

    initial_count = DatabaseBackup.count
    @job.send(:remove_old_backup)
    assert_equal initial_count, DatabaseBackup.count
  end

  test "marks file for purge when removing old backup" do
    DatabaseBackup.delete_all
    4.times do |i|
      backup = DatabaseBackup.create!
      backup.file.attach(
        io: StringIO.new("test content #{i}"),
        filename: "backup_#{i}.sql",
        content_type: "application/x-sqlite3"
      )
    end

    oldest_backup = DatabaseBackup.order(:created_at).first

    @job.send(:remove_old_backup)

    assert_not DatabaseBackup.exists?(oldest_backup.id)
  end

  test "generates filename with date and database basename" do
    @job.stubs(:database_file).returns(@database_path)

    current_date = Time.now.strftime("%Y-%m-%d")
    filename = @job.send(:file_name)
    assert_match(/^#{current_date}-/, filename)
    assert_match(/\.sqlite3$/, filename)
  end

  test "performs job successfully" do
    @job.stubs(:database_file).returns(@database_path)

    backup = @job.perform
    assert_instance_of DatabaseBackup, backup
    assert backup.persisted?
  end

  test "removes backup with attached file" do
    DatabaseBackup.delete_all
    old_backup = DatabaseBackup.create!
    old_backup.file.attach(
      io: StringIO.new("old backup content"),
      filename: "old_backup.sql",
      content_type: "application/x-sqlite3"
    )

    original_blob_id = old_backup.file.blob_id

    old_backup.file.purge
    old_backup.destroy

    assert_not DatabaseBackup.exists?(old_backup.id)
    assert_not ActiveStorage::Blob.exists?(original_blob_id)
  end

  test "orders backups by creation date" do
    DatabaseBackup.delete_all
    backups = []
    3.times do |i|
      backup = DatabaseBackup.create!(created_at: i.days.ago)
      backups << backup
    end

    ordered_backups = DatabaseBackup.order(:created_at).to_a
    assert_equal backups.reverse, ordered_backups
  end

  test "removes single oldest backup" do
    DatabaseBackup.delete_all
    backups = []
    4.times do |i|
      backup = DatabaseBackup.create!(created_at: i.days.ago)
      backup.file.attach(
        io: StringIO.new("test content #{i}"),
        filename: "backup_#{i}.sql",
        content_type: "application/x-sqlite3"
      )
      backups << backup
    end

    oldest_backup = DatabaseBackup.order(:created_at).first

    @job.send(:remove_old_backup)

    assert_not DatabaseBackup.exists?(oldest_backup.id)
    assert_equal 3, DatabaseBackup.count
  end
end
