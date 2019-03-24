class CreateGoogleCredentials < ActiveRecord::Migration[5.2]
  def change
    create_table :google_credentials do |t|
      t.references :user, foreign_key: true, null: false, index: { unique: true }
      t.string :token, null: false
      t.string :refresh_token, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
  end
end
