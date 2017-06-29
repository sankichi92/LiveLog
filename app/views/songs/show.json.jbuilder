json.cache! @song do
  json.extract! @song,
                :id, :name, :artist, :order, :time, :status, :youtube_id, :comment
  json.live @song.live, partial: 'lives/live', as: :live
  json.playings sort_by_inst(@song.playings), partial: 'playings/playing', as: :playing
end
