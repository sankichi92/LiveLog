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

ActiveRecord::Schema.define(version: 20170717132818) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "lives", force: :cascade do |t|
    t.string   "name"
    t.date     "date"
    t.string   "place"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_lives_on_date", using: :btree
    t.index ["name", "date"], name: "index_lives_on_name_and_date", unique: true, using: :btree
  end

  create_table "playings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "song_id"
    t.string   "inst"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["song_id"], name: "index_playings_on_song_id", using: :btree
    t.index ["user_id", "song_id"], name: "index_playings_on_user_id_and_song_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_playings_on_user_id", using: :btree
  end

  create_table "songs", force: :cascade do |t|
    t.string   "name"
    t.string   "artist"
    t.string   "youtube_id"
    t.integer  "live_id"
    t.integer  "order"
    t.time     "time"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "status",     default: 1
    t.text     "comment"
    t.index ["live_id"], name: "index_songs_on_live_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "furigana"
    t.string   "nickname"
    t.string   "email"
    t.integer  "joined"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin",             default: false
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.boolean  "public",            default: false
    t.string   "url"
    t.text     "intro"
    t.string   "api_digest"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["furigana"], name: "index_users_on_furigana", using: :btree
  end

  add_foreign_key "playings", "songs"
  add_foreign_key "playings", "users"
  add_foreign_key "songs", "lives"
end
