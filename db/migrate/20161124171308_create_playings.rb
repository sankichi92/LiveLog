class CreatePlayings < ActiveRecord::Migration[5.0]
  def change
    create_table :playings do |t|
      t.references :user, foreign_key: true, index: true
      t.references :song, foreign_key: true, index: true
      t.string :inst

      t.timestamps
    end
    add_index :playings, [:user_id, :song_id], unique: true
  end
end
