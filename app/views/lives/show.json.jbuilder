json.cache! @live do
  json.partial! 'lives/live', live: @live
  json.songs @live.songs.played_order, partial: 'songs/song', as: :song
end
