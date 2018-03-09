# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180309131630) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "lives", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.date "date", null: false
    t.string "place"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "album_url"
    t.datetime "published_at"
    t.boolean "published", default: false, null: false
    t.index ["date"], name: "index_lives_on_date"
    t.index ["name", "date"], name: "index_lives_on_name_and_date", unique: true
  end

  create_table "playings", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "song_id", null: false
    t.string "inst"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["song_id"], name: "index_playings_on_song_id"
    t.index ["user_id", "song_id"], name: "index_playings_on_user_id_and_song_id", unique: true
    t.index ["user_id"], name: "index_playings_on_user_id"
  end

  create_table "songs", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "artist"
    t.string "youtube_id"
    t.integer "live_id", null: false
    t.integer "order"
    t.time "time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 1
    t.text "comment"
    t.boolean "original", default: false, null: false
    t.index ["live_id"], name: "index_songs_on_live_id"
  end

  create_table "tokens", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "digest", null: false
    t.datetime "created_at", null: false
    t.index ["user_id"], name: "index_tokens_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "furigana", null: false
    t.string "nickname"
    t.string "email"
    t.integer "joined", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false, null: false
    t.string "activation_digest"
    t.boolean "activated", default: false, null: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.boolean "public", default: false, null: false
    t.string "url"
    t.text "intro"
    t.boolean "subscribing", default: true, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["furigana"], name: "index_users_on_furigana"
  end

  add_foreign_key "playings", "songs"
  add_foreign_key "playings", "users"
  add_foreign_key "songs", "lives"
  add_foreign_key "tokens", "users"
end
