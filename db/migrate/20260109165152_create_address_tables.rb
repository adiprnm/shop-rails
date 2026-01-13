class CreateAddressTables < ActiveRecord::Migration[8.0]
  def change
    create_table :provinces do |t|
      t.string :rajaongkir_id, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :provinces, :rajaongkir_id, unique: true

    create_table :cities do |t|
      t.string :rajaongkir_id, null: false
      t.string :name, null: false
      t.references :province, null: false, foreign_key: true

      t.timestamps
    end
    add_index :cities, :rajaongkir_id, unique: true

    create_table :districts do |t|
      t.string :rajaongkir_id, null: false
      t.string :name, null: false
      t.references :city, null: false, foreign_key: true

      t.timestamps
    end
    add_index :districts, :rajaongkir_id, unique: true

    create_table :subdistricts do |t|
      t.string :rajaongkir_id, null: false
      t.string :name, null: false
      t.references :district, null: false, foreign_key: true

      t.timestamps
    end
    add_index :subdistricts, :rajaongkir_id, unique: true
  end
end
