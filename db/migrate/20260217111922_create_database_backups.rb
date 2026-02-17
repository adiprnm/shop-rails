class CreateDatabaseBackups < ActiveRecord::Migration[8.1]
  def change
    create_table :database_backups do |t|
      t.timestamps
    end
  end
end
