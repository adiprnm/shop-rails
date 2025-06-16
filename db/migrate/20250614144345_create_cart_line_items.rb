class CreateCartLineItems < ActiveRecord::Migration[8.0]
  def change
    create_table :cart_line_items do |t|
      t.belongs_to :cart, null: false, foreign_key: true
      t.belongs_to :cartable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
