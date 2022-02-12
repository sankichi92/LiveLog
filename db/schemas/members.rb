# frozen_string_literal: true

create_table :members, force: :cascade do |t|
  t.integer :joined_year, null: false, limit: 2
  t.string :name, null: false
  t.string :url
  t.string :bio
  t.integer :plays_count, null: false, default: 0, limit: 2

  t.timestamps precision: 6

  t.index %i[name joined_year], unique: true
  t.index %i[joined_year plays_count]
end
