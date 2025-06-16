class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.belongs_to :cart, null: false, foreign_key: true
      t.string :order_id, null: false
      t.string :customer_name, null: false
      t.string :customer_email_address, null: false
      t.boolean :customer_agree_to_terms, null: false, default: true
      t.boolean :customer_agree_to_receive_newsletter, null: false, default: false
      t.integer :state, null: false
      t.datetime :state_updated_at
      t.integer :total_price, null: false
      t.json :integration_data, null: false, default: {}

      t.timestamps
    end
  end
end
