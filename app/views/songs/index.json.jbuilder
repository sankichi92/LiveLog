json.array! @songs do |song|
  json.partial! 'songs/song', song: song
  json.live song.live, partial: 'lives/live', as: :live
  json.playings song.playings.order_by_inst, partial: 'playings/playing', as: :playing
end
