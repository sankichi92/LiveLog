json.cache! @user do
  json.extract! @user, :id, :joined, :public, :url, :intro
  json.name @user.handle
end
json.insts do
  json.array! Playing.resolve_insts(@user.playings.count_insts) do |inst, count|
    json.inst inst
    json.count count
  end
end
json.songs do
  json.array! @user.songs.order_by_live do |song|
    json.cache! song do
      json.partial! 'songs/song', song: song
      json.live song.live, partial: 'lives/live', as: :live
    end
  end
end
