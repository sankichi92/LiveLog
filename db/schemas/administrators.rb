# frozen_string_literal: true

create_table :administrators, force: :cascade do |t|
  t.references :user, null: false, index: { unique: true }, foreign_key: true
  t.string :scopes, array: true, null: false, default: []

  t.timestamps
end
