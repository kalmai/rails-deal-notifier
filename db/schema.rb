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

ActiveRecord::Schema[7.1].define(version: 2024_03_05_212120) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contact_methods", force: :cascade do |t|
    t.integer "contact_type", null: false
    t.string "contact_detail", null: false
    t.boolean "enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_contact_methods_on_user_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.string "full_name"
    t.string "short_name"
    t.integer "start_month"
    t.string "end_month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "promotions", force: :cascade do |t|
    t.string "company"
    t.string "name"
    t.integer "promo_type"
    t.string "promo_code"
    t.string "source_url"
    t.integer "redemption_limiter"
    t.integer "redemption_count"
    t.integer "hours_valid"
    t.string "api_methods", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id"
    t.index ["team_id"], name: "index_promotions_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "full_name"
    t.string "short_name"
    t.string "region"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "league_id"
    t.index ["league_id"], name: "index_teams_on_league_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "postal", limit: 15
    t.string "region"
    t.string "country"
    t.string "timezone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
