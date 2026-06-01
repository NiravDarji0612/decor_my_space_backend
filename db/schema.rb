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

ActiveRecord::Schema[8.0].define(version: 2026_05_27_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "add_ons", force: :cascade do |t|
    t.string "key", null: false
    t.string "label", null: false
    t.text "description"
    t.integer "price_cents", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_add_ons_on_key", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "label", default: "Home", null: false
    t.string "recipient_name", null: false
    t.string "line1", null: false
    t.string "line2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country", default: "IN", null: false
    t.string "phone", null: false
    t.boolean "is_default", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "is_default"], name: "index_addresses_on_user_id_and_is_default"
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "booking_add_ons", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.bigint "add_on_id", null: false
    t.integer "price_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["add_on_id"], name: "index_booking_add_ons_on_add_on_id"
    t.index ["booking_id", "add_on_id"], name: "index_booking_add_ons_on_booking_id_and_add_on_id", unique: true
    t.index ["booking_id"], name: "index_booking_add_ons_on_booking_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "design_id", null: false
    t.bigint "decorator_id", null: false
    t.integer "status", default: 0, null: false
    t.string "booking_reference", null: false
    t.string "event_type", null: false
    t.date "event_date", null: false
    t.string "time_slot", null: false
    t.integer "expected_guests", default: 0, null: false
    t.string "venue_name", null: false
    t.string "venue_address_line1", null: false
    t.string "venue_address_line2"
    t.string "contact_full_name", null: false
    t.string "contact_phone", null: false
    t.string "contact_email", null: false
    t.text "special_instructions"
    t.integer "subtotal_cents", default: 0, null: false
    t.integer "gst_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.integer "advance_paid_cents", default: 0, null: false
    t.integer "payment_method", default: 0, null: false
    t.integer "payment_status", default: 0, null: false
    t.datetime "placed_on", null: false
    t.datetime "cancelled_at"
    t.string "cancellation_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_reference"], name: "index_bookings_on_booking_reference", unique: true
    t.index ["decorator_id"], name: "index_bookings_on_decorator_id"
    t.index ["design_id"], name: "index_bookings_on_design_id"
    t.index ["event_date"], name: "index_bookings_on_event_date"
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "slug", null: false
    t.string "title", null: false
    t.string "icon_key"
    t.string "tint_hex"
    t.string "icon_color_hex"
    t.string "cover_url"
    t.jsonb "match_keys", default: [], null: false
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_keys"], name: "index_categories_on_match_keys", using: :gin
    t.index ["position"], name: "index_categories_on_position"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "decorators", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false
    t.string "specialty"
    t.string "tagline"
    t.text "bio"
    t.string "avatar_url"
    t.integer "hourly_rate_cents", default: 0, null: false
    t.integer "review_count", default: 0, null: false
    t.decimal "rating_avg", precision: 3, scale: 2, default: "0.0"
    t.string "area"
    t.string "city"
    t.string "phone"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.boolean "open", default: true, null: false
    t.datetime "location_updated_at"
    t.index ["category"], name: "index_decorators_on_category"
    t.index ["city", "area"], name: "index_decorators_on_city_and_area"
    t.index ["open"], name: "index_decorators_on_open"
    t.index ["rating_avg"], name: "index_decorators_on_rating_avg"
    t.index ["user_id"], name: "index_decorators_on_user_id", unique: true
  end

  create_table "design_images", force: :cascade do |t|
    t.bigint "design_id", null: false
    t.string "url", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["design_id", "position"], name: "index_design_images_on_design_id_and_position"
    t.index ["design_id"], name: "index_design_images_on_design_id"
  end

  create_table "design_inclusions", force: :cascade do |t|
    t.bigint "design_id", null: false
    t.string "label", null: false
    t.string "icon_key"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["design_id", "position"], name: "index_design_inclusions_on_design_id_and_position"
    t.index ["design_id"], name: "index_design_inclusions_on_design_id"
  end

  create_table "designs", force: :cascade do |t|
    t.bigint "decorator_id", null: false
    t.bigint "category_id", null: false
    t.string "title", null: false
    t.string "subtitle"
    t.text "description"
    t.integer "price_cents", default: 0, null: false
    t.string "currency", default: "INR", null: false
    t.decimal "rating_avg", precision: 3, scale: 2, default: "0.0"
    t.integer "review_count", default: 0, null: false
    t.string "hero_image_url"
    t.boolean "available", default: true, null: false
    t.boolean "featured", default: false, null: false
    t.boolean "trending", default: false, null: false
    t.integer "saved_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available"], name: "index_designs_on_available"
    t.index ["category_id"], name: "index_designs_on_category_id"
    t.index ["decorator_id"], name: "index_designs_on_decorator_id"
    t.index ["featured"], name: "index_designs_on_featured"
    t.index ["price_cents"], name: "index_designs_on_price_cents"
    t.index ["trending"], name: "index_designs_on_trending"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "body"
    t.integer "kind", default: 0, null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "read_at"
    t.datetime "delivered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_notifications_on_kind"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "otp_verifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "channel", default: 0, null: false
    t.integer "purpose", default: 0, null: false
    t.string "destination", null: false
    t.string "code_digest", null: false
    t.integer "attempts", default: 0, null: false
    t.datetime "expires_at", null: false
    t.datetime "consumed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "purpose"], name: "index_otp_verifications_on_user_id_and_purpose"
    t.index ["user_id"], name: "index_otp_verifications_on_user_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "kind", default: 0, null: false
    t.string "title", null: false
    t.string "subtitle"
    t.string "last4"
    t.string "provider_token"
    t.date "expires_on"
    t.boolean "is_default", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "is_default"], name: "index_payment_methods_on_user_id_and_is_default"
    t.index ["user_id"], name: "index_payment_methods_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.bigint "user_id", null: false
    t.bigint "decorator_id", null: false
    t.bigint "design_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.jsonb "tags", default: [], null: false
    t.boolean "would_recommend", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_reviews_on_booking_id", unique: true
    t.index ["decorator_id"], name: "index_reviews_on_decorator_id"
    t.index ["design_id"], name: "index_reviews_on_design_id"
    t.index ["rating"], name: "index_reviews_on_rating"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "saved_designs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "design_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["design_id"], name: "index_saved_designs_on_design_id"
    t.index ["user_id", "design_id"], name: "index_saved_designs_on_user_id_and_design_id", unique: true
    t.index ["user_id"], name: "index_saved_designs_on_user_id"
  end

  create_table "support_tickets", force: :cascade do |t|
    t.bigint "user_id"
    t.string "category", null: false
    t.string "subject", null: false
    t.text "message", null: false
    t.string "email"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_support_tickets_on_status"
    t.index ["user_id"], name: "index_support_tickets_on_user_id"
  end

  create_table "user_location_histories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.float "accuracy_m"
    t.string "source", default: "client", null: false
    t.datetime "recorded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "recorded_at"], name: "index_user_location_histories_on_user_id_and_recorded_at"
    t.index ["user_id"], name: "index_user_location_histories_on_user_id"
  end

  create_table "user_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "locale", default: "en", null: false
    t.string "currency", default: "INR", null: false
    t.boolean "dark_mode", default: false, null: false
    t.boolean "location_services", default: true, null: false
    t.boolean "notify_bookings", default: true, null: false
    t.boolean "notify_promotions", default: true, null: false
    t.boolean "notify_system", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_preferences_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.string "password_digest", null: false
    t.integer "account_type", default: 0, null: false
    t.boolean "accepted_terms", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "city"
    t.text "bio"
    t.string "avatar_url"
    t.datetime "email_verified_at"
    t.datetime "phone_verified_at"
    t.datetime "deleted_at"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "location_updated_at"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true, where: "(username IS NOT NULL)"
  end

  add_foreign_key "addresses", "users"
  add_foreign_key "booking_add_ons", "add_ons"
  add_foreign_key "booking_add_ons", "bookings"
  add_foreign_key "bookings", "decorators"
  add_foreign_key "bookings", "designs"
  add_foreign_key "bookings", "users"
  add_foreign_key "decorators", "users"
  add_foreign_key "design_images", "designs"
  add_foreign_key "design_inclusions", "designs"
  add_foreign_key "designs", "categories"
  add_foreign_key "designs", "decorators"
  add_foreign_key "notifications", "users"
  add_foreign_key "otp_verifications", "users"
  add_foreign_key "payment_methods", "users"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "reviews", "decorators"
  add_foreign_key "reviews", "designs"
  add_foreign_key "reviews", "users"
  add_foreign_key "saved_designs", "designs"
  add_foreign_key "saved_designs", "users"
  add_foreign_key "support_tickets", "users"
  add_foreign_key "user_location_histories", "users"
  add_foreign_key "user_preferences", "users"
end
