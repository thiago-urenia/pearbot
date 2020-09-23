# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_22_115516) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "exclusions", force: :cascade do |t|
    t.bigint "excluder_id"
    t.bigint "excluded_participant_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["excluded_participant_id"], name: "index_exclusions_on_excluded_participant_id"
    t.index ["excluder_id"], name: "index_exclusions_on_excluder_id"
  end

  create_table "groupings", force: :cascade do |t|
    t.bigint "round_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["round_id"], name: "index_groupings_on_round_id"
  end

  create_table "groupings_participants", id: false, force: :cascade do |t|
    t.bigint "grouping_id", null: false
    t.bigint "participant_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["grouping_id"], name: "index_groupings_participants_on_grouping_id"
    t.index ["participant_id"], name: "index_groupings_participants_on_participant_id"
  end

  create_table "participants", force: :cascade do |t|
    t.string "slack_user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "pool_entries", force: :cascade do |t|
    t.bigint "pool_id"
    t.bigint "participant_id"
    t.string "status", default: "available"
    t.index ["participant_id"], name: "index_pool_entries_on_participant_id"
    t.index ["pool_id"], name: "index_pool_entries_on_pool_id"
  end

  create_table "pools", force: :cascade do |t|
    t.string "slack_channel_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "rounds", force: :cascade do |t|
    t.bigint "pool_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pool_id"], name: "index_rounds_on_pool_id"
  end

  add_foreign_key "exclusions", "participants", column: "excluded_participant_id"
  add_foreign_key "exclusions", "participants", column: "excluder_id"
end
