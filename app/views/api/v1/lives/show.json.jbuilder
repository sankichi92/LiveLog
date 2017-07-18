json.cache_if! !authenticated?, ['v1', @live] do
  json.partial! 'api/v1/lives/live', live: @live
  json.songs @live.songs.played_order, partial: 'api/v1/songs/song', as: :song
end
