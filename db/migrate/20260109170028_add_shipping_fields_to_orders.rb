class AddShippingFieldsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :customer_phone, :string
    add_column :orders, :address_line, :text
    add_reference :orders, :shipping_province, foreign_key: { to_table: :provinces }
    add_reference :orders, :shipping_city, foreign_key: { to_table: :cities }
    add_reference :orders, :shipping_district, foreign_key: { to_table: :districts }
    add_reference :orders, :shipping_subdistrict, foreign_key: { to_table: :subdistricts }
    add_column :orders, :order_notes, :text
    add_column :orders, :shipping_provider, :string
    add_column :orders, :shipping_method, :string
    add_column :orders, :shipping_cost, :integer

    add_index :orders, :shipping_provider
    add_index :orders, :shipping_method
  end
end
