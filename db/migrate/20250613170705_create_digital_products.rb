class CreateDigitalProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :digital_products do |t|
      t.integer :resource_type, default: 0
      t.string :resource_url

      t.timestamps
    end
  end
end
