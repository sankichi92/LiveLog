json.cache_if! !authenticated?, ['v1', @song] do
  json.extract! @song, :id, :name, :artist, :order, :time
  json.time @song.time_str
  json.youtube_id policy(@song).play? ? @song.youtube_id : ''
  json.comment @song.comment
  json.live @song.live, partial: 'api/v1/lives/live', as: :live
  json.playings @song.playings.sort_by(&:inst_order), partial: 'api/v1/playings/playing', as: :playing
end
