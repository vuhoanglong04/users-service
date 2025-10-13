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

ActiveRecord::Schema[8.0].define(version: 2025_10_10_084105) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.integer "doctor_id", null: false
    t.integer "patient_id", null: false
    t.datetime "appointment_date", null: false
    t.string "status", default: "pending", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "appointment_snapshot"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "user_id", null: false
    t.text "content", null: false
    t.datetime "deleted_at", precision: nil
    t.string "ancestry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ancestry"], name: "index_comments_on_ancestry"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "doctor_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "gender", default: "male"
    t.string "specialization", null: false
    t.string "license_number", null: false
    t.integer "experience_years", default: 0
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "avatar", default: ""
    t.index ["user_id"], name: "index_doctor_profiles_on_user_id"
  end

  create_table "patient_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "date_of_birth"
    t.string "gender", default: "male"
    t.string "address"
    t.string "emergency_contact"
    t.text "medical_history"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "avatar", default: ""
    t.index ["user_id"], name: "index_patient_profiles_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "content", null: false
    t.string "image_url"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.integer "role", default: 1
    t.string "provider"
    t.text "avatar"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "appointments", "doctor_profiles", column: "doctor_id"
  add_foreign_key "appointments", "patient_profiles", column: "patient_id"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "doctor_profiles", "users"
  add_foreign_key "patient_profiles", "users"
  add_foreign_key "posts", "users"
end
