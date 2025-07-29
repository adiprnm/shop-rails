class AddMinimumPriceToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :minimum_price, :integer
  end
end
