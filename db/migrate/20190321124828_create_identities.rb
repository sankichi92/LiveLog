class CreateIdentities < ActiveRecord::Migration[5.2]
  def change
    create_table :identities do |t|
      t.references :user, foreign_key: true, null: false
      t.string :provider, null: false
      t.string :uid, null: false

      t.timestamps
    end

    add_index :identities, %i[user_id provider], unique: true
    add_index :identities, %i[provider uid], unique: true
  end
end
