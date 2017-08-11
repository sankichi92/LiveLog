class CreateTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :tokens do |t|
      t.references :user, foreign_key: true, null: false
      t.string :digest, null: false
      t.datetime :created_at, null: false
    end
  end
end
