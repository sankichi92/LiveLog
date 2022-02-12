# frozen_string_literal: true

create_table :entry_guidelines, force: :cascade do |t|
  t.references :live, null: false, index: { unique: true }, foreign_key: { column: :live_id }
  t.datetime :deadline, null: false
  t.text :notes

  t.timestamps
end
