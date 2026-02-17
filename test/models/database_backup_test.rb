require "test_helper"

class DatabaseBackupTest < ActiveSupport::TestCase
  setup do
    @backup = DatabaseBackup.new
  end

  test "has_one_attached file" do
    assert_respond_to @backup, :file
  end

  test "can attach a file to backup" do
    @backup.file.attach(
      io: StringIO.new("test content"),
      filename: "example.txt",
      content_type: "text/plain"
    )
    assert @backup.file.attached?
  end

  test "creates valid backup with attached file" do
    backup = DatabaseBackup.create!(
      file: {
        io: StringIO.new("test content"),
        filename: "backup.sql",
        content_type: "application/x-sqlite3"
      }
    )
    assert backup.persisted?
    assert backup.file.attached?
  end

  test "timestamps are set on creation" do
    backup = DatabaseBackup.create!(
      file: {
        io: StringIO.new("test content"),
        filename: "backup.sql",
        content_type: "application/x-sqlite3"
      }
    )
    assert_not_nil backup.created_at
    assert_not_nil backup.updated_at
  end
end
