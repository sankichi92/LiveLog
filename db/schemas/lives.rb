# frozen_string_literal: true

create_table :lives, force: :cascade do |t|
  t.string :name, null: false
  t.date :date, null: false
  t.string :place
  t.text :comment
  t.string :album_url
  t.boolean :published, null: false, default: false
  t.datetime :published_at, precision: 6
  t.integer :songs_count, null: false, default: 0, limit: 2

  t.timestamps precision: 6

  t.index %i[date name], unique: true
  t.index %i[published date]
end
