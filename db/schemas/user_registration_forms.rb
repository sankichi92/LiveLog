# frozen_string_literal: true

create_table :user_registration_forms, force: :cascade do |t|
  t.references :admin, null: false
  t.string :token, null: false
  t.datetime :expires_at, null: false, precision: 6
  t.integer :used_count, null: false, default: 0

  t.timestamps precision: 6

  t.index :token, unique: true
  t.foreign_key :administrators, column: :admin_id
end
