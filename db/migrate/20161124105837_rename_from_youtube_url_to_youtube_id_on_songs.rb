class RenameFromYoutubeUrlToYoutubeIdOnSongs < ActiveRecord::Migration[5.0]
  def change
    rename_column :songs, :youtube_url, :youtube_id
  end
end
