class AddZipCodeToCities < ActiveRecord::Migration[8.0]
  def change
    add_column :cities, :zip_code, :string
  end
end
