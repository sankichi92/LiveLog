# frozen_string_literal: true

create_table :clients, force: :cascade do |t|
  t.references :developer, null: false, foreign_key: true
  t.string :auth0_id, null: false
  t.string :name, null: false
  t.string :description
  t.string :logo_url, null: false
  t.string :livelog_grant_id

  t.timestamps precision: 6

  t.index :auth0_id, unique: true
end
