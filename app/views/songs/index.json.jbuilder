json.array! @songs do |song|
  json.cache! song do
    json.partial! 'songs/song', song: song
    json.live song.live, partial: 'lives/live', as: :live
  end
end
