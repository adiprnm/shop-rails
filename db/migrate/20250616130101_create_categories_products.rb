class CreateCategoriesProducts < ActiveRecord::Migration[8.0]
  def change
    create_join_table :categories, :products
  end
end
