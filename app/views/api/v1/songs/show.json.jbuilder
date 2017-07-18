json.cache_if! !authenticated?, ['v1', @song] do
  json.extract! @song, :id, :name, :artist, :order, :time, :comment
  json.time @song.time_str
  json.youtube_id can_watch?(@song) ? @song.youtube_id : ''
  json.live @song.live, partial: 'api/v1/lives/live', as: :live
  json.playings sort_by_inst(@song.playings), partial: 'api/v1/playings/playing', as: :playing
end
