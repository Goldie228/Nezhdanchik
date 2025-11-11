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

ActiveRecord::Schema[7.2].define(version: 2025_11_08_190830) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "cart_item_ingredients", force: :cascade do |t|
    t.bigint "cart_item_id", null: false
    t.bigint "ingredient_id", null: false
    t.boolean "included", default: true, null: false
    t.boolean "default_in_dish", default: true, null: false
    t.integer "price", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_item_id", "ingredient_id"], name: "index_cart_item_ingredients_on_cart_item_id_and_ingredient_id", unique: true
    t.index ["cart_item_id"], name: "index_cart_item_ingredients_on_cart_item_id"
    t.index ["ingredient_id"], name: "index_cart_item_ingredients_on_ingredient_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "cart_id", null: false
    t.integer "quantity", default: 1, null: false
    t.boolean "active", default: true, null: false
    t.bigint "dish_id", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["dish_id"], name: "index_cart_items_on_dish_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "slug", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "dish_ingredients", force: :cascade do |t|
    t.bigint "dish_id", null: false
    t.bigint "ingredient_id", null: false
    t.boolean "default", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["default"], name: "index_dish_ingredients_on_default"
    t.index ["dish_id", "ingredient_id"], name: "index_dish_ingredients_on_dish_id_and_ingredient_id", unique: true
    t.index ["dish_id"], name: "index_dish_ingredients_on_dish_id"
    t.index ["ingredient_id"], name: "index_dish_ingredients_on_ingredient_id"
  end

  create_table "dishes", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "slug", null: false
    t.boolean "active", default: true
    t.integer "cooking_time_minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
    t.integer "weight", default: 100, null: false
    t.index ["active"], name: "index_dishes_on_active"
    t.index ["category_id"], name: "index_dishes_on_category_id"
    t.index ["price"], name: "index_dishes_on_price"
    t.index ["slug"], name: "index_dishes_on_slug", unique: true
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "price", precision: 8, scale: 2, default: "0.0"
    t.boolean "available", default: true
    t.boolean "allergen", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "weight", default: 10, null: false
    t.index ["available"], name: "index_ingredients_on_available"
    t.index ["name"], name: "index_ingredients_on_name", unique: true
  end

  create_table "nutritions", force: :cascade do |t|
    t.decimal "proteins", precision: 5, scale: 2
    t.decimal "fats", precision: 5, scale: 2
    t.decimal "carbohydrates", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "dish_id"
    t.bigint "ingredient_id"
    t.index ["dish_id"], name: "index_nutritions_on_dish_id"
    t.index ["ingredient_id"], name: "index_nutritions_on_ingredient_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "phone", null: false
    t.string "first_name", limit: 255, null: false
    t.string "last_name", limit: 255, null: false
    t.string "middle_name", limit: 255
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest", null: false
    t.string "email_otp_code"
    t.datetime "email_otp_sent_at"
    t.integer "email_otp_attempts", default: 0, null: false
    t.boolean "two_factor_enabled", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email_otp_code"], name: "index_users_on_email_otp_code"
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cart_item_ingredients", "cart_items"
  add_foreign_key "cart_item_ingredients", "ingredients"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "dishes"
  add_foreign_key "carts", "users"
  add_foreign_key "dish_ingredients", "dishes"
  add_foreign_key "dish_ingredients", "ingredients"
  add_foreign_key "dishes", "categories"
  add_foreign_key "nutritions", "dishes"
  add_foreign_key "nutritions", "ingredients"
end
