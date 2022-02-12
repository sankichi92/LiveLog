# frozen_string_literal: true

create_table :users, force: :cascade do |t|
  t.references :member, null: false, index: { unique: true }, foreign_key: true
  t.string :auth0_id, null: false
  t.string :email, null: false
  t.jsonb :userinfo, null: false, default: {}
  t.boolean :activated, default: false, null: false

  t.timestamps precision: 6

  t.index :auth0_id, unique: true
  t.index :email, unique: true
  t.index :activated
end
