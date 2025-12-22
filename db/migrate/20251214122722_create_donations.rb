class CreateDonations < ActiveRecord::Migration[8.0]
  def change
    create_table :donations do |t|
      t.string :name
      t.string :message
      t.integer :amount, null: false
      t.string :state, null: false
      t.datetime :state_updated_at
      t.string :donation_id, null: false
      t.json :integration_data, null: false, default: {}

      t.timestamps
    end
  end
end
