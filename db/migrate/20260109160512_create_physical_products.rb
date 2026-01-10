class CreatePhysicalProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :physical_products do |t|
      t.timestamps
    end
  end
end
