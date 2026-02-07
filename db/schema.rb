# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_07_175053) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cart_line_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.integer "cartable_id", null: false
    t.string "cartable_type", null: false
    t.datetime "created_at", null: false
    t.integer "price"
    t.integer "product_variant_id"
    t.integer "quantity", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_line_items_on_cart_id"
    t.index ["cartable_type", "cartable_id"], name: "index_cart_line_items_on_cartable"
    t.index ["product_variant_id"], name: "index_cart_line_items_on_product_variant_id"
  end

  create_table "carts", force: :cascade do |t|
    t.string "coupon_code"
    t.datetime "created_at", null: false
    t.string "session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["coupon_code"], name: "index_carts_on_coupon_code"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories_products", id: false, force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "product_id", null: false
  end

  create_table "cities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "province_id", null: false
    t.string "rajaongkir_id", null: false
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["name"], name: "index_cities_on_name"
    t.index ["province_id"], name: "index_cities_on_province_id"
    t.index ["rajaongkir_id"], name: "index_cities_on_rajaongkir_id", unique: true
  end

  create_table "coupon_restrictions", force: :cascade do |t|
    t.integer "coupon_id", null: false
    t.datetime "created_at", null: false
    t.integer "restriction_id", null: false
    t.string "restriction_kind", default: "include", null: false
    t.string "restriction_type", null: false
    t.datetime "updated_at", null: false
    t.index ["coupon_id", "restriction_type", "restriction_id", "restriction_kind"], name: "index_coupon_restrictions_unique", unique: true
    t.index ["coupon_id"], name: "index_coupon_restrictions_on_coupon_id"
    t.index ["restriction_type", "restriction_id"], name: "index_coupon_restrictions_on_polymorphic"
  end

  create_table "coupon_usages", force: :cascade do |t|
    t.integer "coupon_id", null: false
    t.datetime "created_at", null: false
    t.integer "discount_amount", null: false
    t.integer "order_id", null: false
    t.datetime "updated_at", null: false
    t.index ["coupon_id"], name: "index_coupon_usages_on_coupon_id"
    t.index ["order_id"], name: "index_coupon_usages_on_order_id"
  end

  create_table "coupons", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "discount_amount"
    t.string "discount_type", null: false
    t.boolean "exclude_sale_items", default: false, null: false
    t.datetime "expires_at"
    t.integer "maximum_amount"
    t.integer "minimum_amount", default: 0, null: false
    t.datetime "starts_at"
    t.string "state", default: "active", null: false
    t.datetime "updated_at", null: false
    t.integer "usage_count", default: 0, null: false
    t.integer "usage_limit"
    t.integer "usage_limit_per_user", default: 0, null: false
    t.index ["code"], name: "index_coupons_on_code", unique: true
    t.index ["expires_at"], name: "index_coupons_on_expires_at"
    t.index ["state"], name: "index_coupons_on_state"
  end

  create_table "digital_products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "resource_type", default: 0
    t.string "resource_url"
    t.datetime "updated_at", null: false
  end

  create_table "districts", force: :cascade do |t|
    t.integer "city_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "rajaongkir_id", null: false
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["city_id"], name: "index_districts_on_city_id"
    t.index ["name"], name: "index_districts_on_name"
    t.index ["rajaongkir_id"], name: "index_districts_on_rajaongkir_id", unique: true
  end

  create_table "donation_payment_evidences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "donation_id", null: false
    t.datetime "updated_at", null: false
    t.index ["donation_id"], name: "index_donation_payment_evidences_on_donation_id"
  end

  create_table "donations", force: :cascade do |t|
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.string "donation_id", null: false
    t.string "email_address"
    t.json "integration_data", default: {}, null: false
    t.string "message"
    t.string "name"
    t.string "remark"
    t.string "state", null: false
    t.datetime "state_updated_at"
    t.datetime "updated_at", null: false
  end

  create_table "order_line_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.integer "orderable_id", null: false
    t.string "orderable_name", null: false
    t.integer "orderable_price", null: false
    t.string "orderable_type", null: false
    t.integer "product_variant_id"
    t.string "product_variant_name"
    t.integer "productable_id"
    t.string "productable_type"
    t.datetime "updated_at", null: false
    t.integer "weight"
    t.index ["order_id"], name: "index_order_line_items_on_order_id"
    t.index ["orderable_type", "orderable_id"], name: "index_order_line_items_on_cartable"
    t.index ["product_variant_id"], name: "index_order_line_items_on_product_variant_id"
    t.index ["productable_type", "productable_id"], name: "index_order_line_items_on_productable"
  end

  create_table "orders", force: :cascade do |t|
    t.text "address_line"
    t.integer "cart_id", null: false
    t.string "coupon_code"
    t.integer "coupon_discount_amount", default: 0, null: false
    t.datetime "created_at", null: false
    t.boolean "customer_agree_to_receive_newsletter", default: false, null: false
    t.boolean "customer_agree_to_terms", default: true, null: false
    t.string "customer_email_address", null: false
    t.string "customer_name", null: false
    t.string "customer_phone"
    t.boolean "has_physical_products"
    t.json "integration_data", default: {}, null: false
    t.string "order_id", null: false
    t.text "order_notes"
    t.string "remark"
    t.integer "shipping_city_id"
    t.integer "shipping_cost"
    t.integer "shipping_cost_id"
    t.integer "shipping_district_id"
    t.string "shipping_method"
    t.string "shipping_provider"
    t.integer "shipping_province_id"
    t.integer "shipping_subdistrict_id"
    t.integer "state", null: false
    t.datetime "state_updated_at"
    t.integer "total_price", null: false
    t.string "tracking_number"
    t.datetime "tracking_number_updated_at"
    t.integer "unique_code"
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_orders_on_cart_id"
    t.index ["coupon_code"], name: "index_orders_on_coupon_code"
    t.index ["has_physical_products"], name: "index_orders_on_has_physical_products"
    t.index ["shipping_city_id"], name: "index_orders_on_shipping_city_id"
    t.index ["shipping_cost_id"], name: "index_orders_on_shipping_cost_id"
    t.index ["shipping_district_id"], name: "index_orders_on_shipping_district_id"
    t.index ["shipping_method"], name: "index_orders_on_shipping_method"
    t.index ["shipping_provider"], name: "index_orders_on_shipping_provider"
    t.index ["shipping_province_id"], name: "index_orders_on_shipping_province_id"
    t.index ["shipping_subdistrict_id"], name: "index_orders_on_shipping_subdistrict_id"
  end

  create_table "pages", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.string "slug", null: false
    t.string "state", null: false
    t.datetime "state_updated_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_evidences", force: :cascade do |t|
    t.boolean "checked", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "payable_id", null: false
    t.string "payable_type", null: false
    t.datetime "updated_at", null: false
  end

  create_table "physical_products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "requires_shipping"
    t.datetime "updated_at", null: false
    t.integer "weight"
  end

  create_table "product_recommendations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.string "recommendation_type", default: "upsell", null: false
    t.integer "recommended_product_id", null: false
    t.integer "source_product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["recommended_product_id"], name: "index_product_recommendations_on_recommended_product"
    t.index ["source_product_id", "recommendation_type", "position"], name: "index_product_recommendations_ordered"
    t.index ["source_product_id", "recommended_product_id", "recommendation_type"], name: "index_unique_recommendation", unique: true
    t.index ["source_product_id"], name: "index_product_recommendations_on_source_product"
  end

  create_table "product_variants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_active"
    t.string "name"
    t.integer "price"
    t.integer "product_id", null: false
    t.integer "stock"
    t.datetime "updated_at", null: false
    t.integer "weight"
    t.index ["product_id"], name: "index_product_variants_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "display_type"
    t.integer "minimum_price"
    t.string "name", null: false
    t.integer "price", null: false
    t.integer "productable_id", null: false
    t.string "productable_type", null: false
    t.integer "sale_price"
    t.datetime "sale_price_ends_at"
    t.datetime "sale_price_starts_at"
    t.string "short_description"
    t.string "slug", null: false
    t.integer "state", default: 1
    t.datetime "updated_at", null: false
  end

  create_table "provinces", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "rajaongkir_id", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_provinces_on_name"
    t.index ["rajaongkir_id"], name: "index_provinces_on_rajaongkir_id", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key"
    t.datetime "updated_at", null: false
    t.json "value"
  end

  create_table "shipping_costs", force: :cascade do |t|
    t.integer "cost"
    t.string "courier"
    t.datetime "created_at", null: false
    t.string "description"
    t.integer "destination_id"
    t.string "destination_type"
    t.integer "origin_id"
    t.string "origin_type"
    t.datetime "price_updated_at"
    t.string "service"
    t.datetime "updated_at", null: false
    t.string "value"
    t.integer "weight"
    t.index ["origin_type", "origin_id", "destination_type", "destination_id", "weight", "courier", "service"], name: "index_shipping_costs_unique", unique: true
  end

  create_table "subdistricts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "district_id", null: false
    t.string "name", null: false
    t.string "rajaongkir_id", null: false
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["district_id"], name: "index_subdistricts_on_district_id"
    t.index ["name"], name: "index_subdistricts_on_name"
    t.index ["rajaongkir_id"], name: "index_subdistricts_on_rajaongkir_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cart_line_items", "carts"
  add_foreign_key "cart_line_items", "product_variants"
  add_foreign_key "cities", "provinces"
  add_foreign_key "coupon_restrictions", "coupons"
  add_foreign_key "coupon_usages", "coupons"
  add_foreign_key "coupon_usages", "orders"
  add_foreign_key "districts", "cities"
  add_foreign_key "donation_payment_evidences", "donations"
  add_foreign_key "order_line_items", "orders"
  add_foreign_key "order_line_items", "product_variants"
  add_foreign_key "orders", "carts"
  add_foreign_key "orders", "cities", column: "shipping_city_id"
  add_foreign_key "orders", "districts", column: "shipping_district_id"
  add_foreign_key "orders", "provinces", column: "shipping_province_id"
  add_foreign_key "orders", "shipping_costs"
  add_foreign_key "orders", "subdistricts", column: "shipping_subdistrict_id"
  add_foreign_key "product_recommendations", "products", column: "recommended_product_id"
  add_foreign_key "product_recommendations", "products", column: "source_product_id"
  add_foreign_key "product_variants", "products"
  add_foreign_key "subdistricts", "districts"
end
