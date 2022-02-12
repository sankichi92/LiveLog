# frozen_string_literal: true

create_table :avatars, force: :cascade do |t|
  t.references :member, null: false, index: { unique: true }, foreign_key: true
  t.string :cloudinary_id, null: false
  t.integer :version, null: false
  t.jsonb :metadata, null: false, default: {}

  t.timestamps
end
