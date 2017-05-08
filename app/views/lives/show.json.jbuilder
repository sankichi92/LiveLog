json.partial! 'lives/live', live: @live
json.songs do
  json.array! @songs do |song|
    json.partial! 'songs/song', song: song
    json.playings song.playings.order_by_inst, partial: 'playings/playing', as: :playing
  end
end
