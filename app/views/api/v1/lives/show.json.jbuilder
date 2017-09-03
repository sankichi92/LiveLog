json.cache_if! !authenticated?, ['v1', @live] do
  json.extract! @live, :id, :name, :date, :place, :album_url
  json.songs @live.songs.played_order, partial: 'api/v1/songs/song', as: :song
end
