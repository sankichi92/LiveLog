# frozen_string_literal: true

create_table :auth0_credentials, force: :cascade do |t|
  t.references :user, null: false, index: { unique: true }, foreign_key: true
  t.string :access_token, null: false
  t.string :refresh_token
  t.datetime :expires_at, null: false, precision: 6

  t.timestamps precision: 6
end
