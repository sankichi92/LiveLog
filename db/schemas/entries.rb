# frozen_string_literal: true

create_table :entries, force: :cascade do |t|
  t.references :song, null: false, index: { unique: true }, foreign_key: true
  t.references :member, null: false, foreign_key: true
  t.text :notes
  t.text :admin_memo

  t.timestamps precision: 6
end

create_table :playable_times, force: :cascade do |t|
  t.references :entry, null: false, foreign_key: true
  t.tsrange :range, null: false

  t.timestamps precision: 6

  t.index :range, using: :gist
end
