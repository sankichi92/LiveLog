class CreateSongs < ActiveRecord::Migration[5.0]
  def change
    create_table :songs do |t|
      t.string :name
      t.string :artist
      t.string :youtube_url
      t.references :lives, foreign_key: true
      t.integer :order
      t.time :time

      t.timestamps
    end
  end
end
