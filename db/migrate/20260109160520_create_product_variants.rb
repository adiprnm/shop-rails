class CreateProductVariants < ActiveRecord::Migration[8.0]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :name
      t.integer :price
      t.integer :weight
      t.integer :stock
      t.boolean :is_active

      t.timestamps
    end
  end
end
