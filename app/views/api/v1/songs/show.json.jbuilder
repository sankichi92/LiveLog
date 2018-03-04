json.cache_if! !authenticated?, ['v1', @song] do
  json.extract! @song, :id, :name, :artist, :order, :time
  json.time @song.time_str
  json.youtube_id @song.visible?(@current_user) ? @song.youtube_id : ''
  json.comment @song.visible?(@current_user) ? @song.comment : ''
  json.live @song.live, partial: 'api/v1/lives/live', as: :live
  json.playings @song.playings.sort_by_inst, partial: 'api/v1/playings/playing', as: :playing
end
