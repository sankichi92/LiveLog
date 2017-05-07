json.extract! song, :id, :name, :artist, :order, :time
json.live do
  json.partial! 'lives/live', live: song.live
end
json.playings do
  json.array! song.playings.order_by_inst, partial: 'playings/playing', as: :playing
end
