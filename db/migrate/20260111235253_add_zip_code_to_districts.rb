class AddZipCodeToDistricts < ActiveRecord::Migration[8.0]
  def change
    add_column :districts, :zip_code, :string
  end
end
