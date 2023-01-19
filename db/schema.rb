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

ActiveRecord::Schema[7.0].define(version: 2023_01_19_153407) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "ticker"
    t.string "industry"
    t.string "sector"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "days", force: :cascade do |t|
    t.date "date"
    t.integer "number_over_50_day"
    t.integer "total_active_companies"
    t.decimal "percentage_over_50"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "records", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "day_id", null: false
    t.date "date", null: false
    t.decimal "high", precision: 15, scale: 4, null: false
    t.decimal "low", precision: 15, scale: 4, null: false
    t.decimal "open", precision: 15, scale: 4, null: false
    t.decimal "close", precision: 15, scale: 4, null: false
    t.integer "volume", null: false
    t.decimal "sma_10", precision: 15, scale: 4
    t.decimal "sma_20", precision: 15, scale: 4
    t.decimal "sma_30", precision: 15, scale: 4
    t.decimal "sma_50", precision: 15, scale: 4
    t.decimal "sma_100", precision: 15, scale: 4
    t.decimal "sma_200", precision: 15, scale: 4
    t.decimal "per_move_100_200", precision: 15, scale: 4
    t.decimal "per_move_50_200", precision: 15, scale: 4
    t.decimal "per_move_30_200", precision: 15, scale: 4
    t.decimal "per_move_20_200", precision: 15, scale: 4
    t.decimal "per_move_10_200", precision: 15, scale: 4
    t.decimal "per_move_close_50", precision: 15, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_records_on_company_id"
    t.index ["day_id"], name: "index_records_on_day_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "records", "companies"
  add_foreign_key "records", "days"
end
