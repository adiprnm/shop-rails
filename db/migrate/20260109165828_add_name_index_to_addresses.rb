class AddNameIndexToAddresses < ActiveRecord::Migration[8.0]
  def change
    add_index :provinces, :name
    add_index :cities, :name
    add_index :districts, :name
    add_index :subdistricts, :name
  end
end
