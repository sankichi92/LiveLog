json.array! @songs do |song|
  json.partial! 'songs/song', song: song
  json.live song.live, partial: 'lives/live', as: :live
end
