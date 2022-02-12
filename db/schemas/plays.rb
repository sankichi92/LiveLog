# frozen_string_literal: true

create_table :plays, force: :cascade do |t|
  t.references :member, null: false, index: false, foreign_key: true
  t.references :song, null: false, foreign_key: true
  t.string :instrument

  t.timestamps precision: 6

  t.index %i[member_id song_id], unique: true
end
