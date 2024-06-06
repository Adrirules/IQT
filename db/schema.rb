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

ActiveRecord::Schema[7.0].define(version: 2024_06_03_100958) do
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

  create_table "guest_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "session_id"
    t.string "unique_identifier"
    t.index ["session_id"], name: "index_guest_users_on_session_id", unique: true
    t.index ["unique_identifier"], name: "index_guest_users_on_unique_identifier", unique: true
  end

  create_table "iqtests", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "start_time"
    t.integer "price_cents", default: 0, null: false
    t.integer "sku"
    t.string "image"
    t.index ["user_id"], name: "index_iqtests_on_user_id"
  end

  create_table "options", force: :cascade do |t|
    t.text "reponse"
    t.boolean "isreponsecorrect"
    t.string "image"
    t.bigint "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_options_on_question_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "state"
    t.string "iqtest_sku"
    t.integer "amount_cents"
    t.string "checkout_session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "iqtest_id"
    t.string "responder_type"
    t.bigint "responder_id"
    t.index ["responder_type", "responder_id"], name: "index_orders_on_responder"
  end

  create_table "questions", force: :cascade do |t|
    t.text "contentq"
    t.bigint "iqtest_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "imageq"
    t.index ["iqtest_id"], name: "index_questions_on_iqtest_id"
  end

  create_table "responses", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "option_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "responder_type", null: false
    t.bigint "responder_id", null: false
    t.index ["option_id"], name: "index_responses_on_option_id"
    t.index ["question_id"], name: "index_responses_on_question_id"
    t.index ["responder_type", "responder_id"], name: "index_responses_on_responder"
  end

  create_table "user_test_scores", force: :cascade do |t|
    t.bigint "iqtest_id", null: false
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "user_type"
    t.bigint "question_id", null: false
    t.bigint "option_id", null: false
    t.string "responder_type"
    t.integer "responder_id"
    t.index ["iqtest_id"], name: "index_user_test_scores_on_iqtest_id"
    t.index ["option_id"], name: "index_user_test_scores_on_option_id"
    t.index ["question_id"], name: "index_user_test_scores_on_question_id"
    t.index ["responder_type", "responder_id"], name: "index_user_test_scores_on_responder_type_and_responder_id"
    t.index ["user_type", "user_id"], name: "index_user_test_scores_on_user_type_and_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.boolean "admin", default: false, null: false
    t.string "user_type"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "iqtests", "users"
  add_foreign_key "options", "questions"
  add_foreign_key "questions", "iqtests"
  add_foreign_key "responses", "options"
  add_foreign_key "responses", "questions"
  add_foreign_key "user_test_scores", "iqtests"
  add_foreign_key "user_test_scores", "options"
  add_foreign_key "user_test_scores", "questions"
end
