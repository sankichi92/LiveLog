# frozen_string_literal: true

create_table :donations, force: :cascade do |t|
  t.references :member, null: false, foreign_key: true
  t.integer :amount, null: false
  t.date :donated_on, null: false

  t.datetime :created_at, null: false

  t.index :donated_on
end
