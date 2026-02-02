class CreatePages < ActiveRecord::Migration[8.0]
  def change
    create_table :pages do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :description, null: false
      t.text :content
      t.string :state, null: false
      t.datetime :state_updated_at

      t.timestamps
    end
  end
end
