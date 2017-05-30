json.cache! @song do
  json.extract! @song, :id, :name, :artist, :order, :time, :youtube_id, :comment
  json.live @song.live, partial: 'lives/live', as: :live
  json.playings @song.playings, partial: 'playings/playing', as: :playing
end
