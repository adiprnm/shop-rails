class AddDisplayTypeToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :display_type, :string
  end
end
