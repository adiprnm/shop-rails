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

ActiveRecord::Schema[8.0].define(version: 2026_01_12_044100) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cart_line_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.string "cartable_type", null: false
    t.integer "cartable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price"
    t.integer "product_variant_id"
    t.integer "quantity", default: 1, null: false
    t.index ["cart_id"], name: "index_cart_line_items_on_cart_id"
    t.index ["cartable_type", "cartable_id"], name: "index_cart_line_items_on_cartable"
    t.index ["product_variant_id"], name: "index_cart_line_items_on_product_variant_id"
  end

  create_table "carts", force: :cascade do |t|
    t.string "session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories_products", id: false, force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "product_id", null: false
  end

  create_table "cities", force: :cascade do |t|
    t.string "rajaongkir_id", null: false
    t.string "name", null: false
    t.integer "province_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["name"], name: "index_cities_on_name"
    t.index ["province_id"], name: "index_cities_on_province_id"
    t.index ["rajaongkir_id"], name: "index_cities_on_rajaongkir_id", unique: true
  end

  create_table "digital_products", force: :cascade do |t|
    t.integer "resource_type", default: 0
    t.string "resource_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "districts", force: :cascade do |t|
    t.string "rajaongkir_id", null: false
    t.string "name", null: false
    t.integer "city_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["city_id"], name: "index_districts_on_city_id"
    t.index ["name"], name: "index_districts_on_name"
    t.index ["rajaongkir_id"], name: "index_districts_on_rajaongkir_id", unique: true
  end

  create_table "donation_payment_evidences", force: :cascade do |t|
    t.integer "donation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["donation_id"], name: "index_donation_payment_evidences_on_donation_id"
  end

  create_table "donations", force: :cascade do |t|
    t.string "name"
    t.string "message"
    t.integer "amount", null: false
    t.string "state", null: false
    t.datetime "state_updated_at"
    t.string "donation_id", null: false
    t.json "integration_data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remark"
    t.string "email_address"
  end

  create_table "order_line_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.string "orderable_type", null: false
    t.integer "orderable_id", null: false
    t.string "orderable_name", null: false
    t.integer "orderable_price", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "productable_type"
    t.integer "productable_id"
    t.integer "product_variant_id"
    t.integer "weight"
    t.index ["order_id"], name: "index_order_line_items_on_order_id"
    t.index ["orderable_type", "orderable_id"], name: "index_order_line_items_on_cartable"
    t.index ["product_variant_id"], name: "index_order_line_items_on_product_variant_id"
    t.index ["productable_type", "productable_id"], name: "index_order_line_items_on_productable"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.string "order_id", null: false
    t.string "customer_name", null: false
    t.string "customer_email_address", null: false
    t.boolean "customer_agree_to_terms", default: true, null: false
    t.boolean "customer_agree_to_receive_newsletter", default: false, null: false
    t.integer "state", null: false
    t.datetime "state_updated_at"
    t.integer "total_price", null: false
    t.json "integration_data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remark"
    t.string "customer_phone"
    t.text "address_line"
    t.integer "shipping_province_id"
    t.integer "shipping_city_id"
    t.integer "shipping_district_id"
    t.integer "shipping_subdistrict_id"
    t.text "order_notes"
    t.string "shipping_provider"
    t.string "shipping_method"
    t.integer "shipping_cost"
    t.boolean "has_physical_products"
    t.index ["cart_id"], name: "index_orders_on_cart_id"
    t.index ["has_physical_products"], name: "index_orders_on_has_physical_products"
    t.index ["shipping_city_id"], name: "index_orders_on_shipping_city_id"
    t.index ["shipping_district_id"], name: "index_orders_on_shipping_district_id"
    t.index ["shipping_method"], name: "index_orders_on_shipping_method"
    t.index ["shipping_provider"], name: "index_orders_on_shipping_provider"
    t.index ["shipping_province_id"], name: "index_orders_on_shipping_province_id"
    t.index ["shipping_subdistrict_id"], name: "index_orders_on_shipping_subdistrict_id"
  end

  create_table "payment_evidences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "payable_id", null: false
    t.string "payable_type", null: false
    t.boolean "checked", default: false, null: false
  end

  create_table "physical_products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "weight"
    t.boolean "requires_shipping"
  end

  create_table "product_variants", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "name"
    t.integer "price"
    t.integer "weight"
    t.integer "stock"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_variants_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.string "short_description"
    t.text "description"
    t.integer "price", null: false
    t.integer "sale_price"
    t.datetime "sale_price_starts_at"
    t.datetime "sale_price_ends_at"
    t.string "slug", null: false
    t.integer "productable_id", null: false
    t.string "productable_type", null: false
    t.integer "state", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "minimum_price"
  end

  create_table "provinces", force: :cascade do |t|
    t.string "rajaongkir_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_provinces_on_name"
    t.index ["rajaongkir_id"], name: "index_provinces_on_rajaongkir_id", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "key"
    t.json "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shipping_costs", force: :cascade do |t|
    t.string "origin_type"
    t.integer "origin_id"
    t.string "destination_type"
    t.integer "destination_id"
    t.integer "weight"
    t.string "courier"
    t.string "service"
    t.string "description"
    t.integer "cost"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["origin_type", "origin_id", "destination_type", "destination_id", "weight", "courier", "service"], name: "index_shipping_costs_unique", unique: true
  end

  create_table "subdistricts", force: :cascade do |t|
    t.string "rajaongkir_id", null: false
    t.string "name", null: false
    t.integer "district_id", null: false
    t.datetime "created_at", null: false
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
  add_foreign_key "districts", "cities"
  add_foreign_key "donation_payment_evidences", "donations"
  add_foreign_key "order_line_items", "orders"
  add_foreign_key "order_line_items", "product_variants"
  add_foreign_key "orders", "carts"
  add_foreign_key "orders", "cities", column: "shipping_city_id"
  add_foreign_key "orders", "districts", column: "shipping_district_id"
  add_foreign_key "orders", "provinces", column: "shipping_province_id"
  add_foreign_key "orders", "subdistricts", column: "shipping_subdistrict_id"
  add_foreign_key "product_variants", "products"
  add_foreign_key "subdistricts", "districts"
end
