class AddOriginalToSongs < ActiveRecord::Migration[5.1]
  def change
    add_column :songs, :original, :boolean, null: false, default: false
  end
end
