# frozen_string_literal: true

create_table :songs, force: :cascade do |t|
  t.references :live, null: false, foreign_key: { column: :live_id }
  t.time :time
  t.integer :position, null: false, limit: 2
  t.string :name, null: false
  t.string :artist
  t.boolean :original, null: false, default: false
  t.integer :visibility, null: false, default: 1, limit: 2
  t.string :youtube_id
  t.text :comment

  t.timestamps
end
