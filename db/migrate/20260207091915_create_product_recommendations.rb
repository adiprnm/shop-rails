class CreateProductRecommendations < ActiveRecord::Migration[8.0]
  def change
    create_table :product_recommendations do |t|
      t.references :source_product, null: false, foreign_key: { to_table: :products }, index: { name: "index_product_recommendations_on_source_product" }
      t.references :recommended_product, null: false, foreign_key: { to_table: :products }, index: { name: "index_product_recommendations_on_recommended_product" }
      t.string :recommendation_type, null: false, default: "upsell"
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :product_recommendations, [ :source_product_id, :recommendation_type, :position ], name: "index_product_recommendations_ordered"
    add_index :product_recommendations, [ :source_product_id, :recommended_product_id, :recommendation_type ], name: "index_unique_recommendation", unique: true
  end
end
