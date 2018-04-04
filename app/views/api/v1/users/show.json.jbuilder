json.cache_if! !authenticated?, ['v1', @user] do
  json.extract! @user, :id, :joined, :public, :url, :intro
  json.name authenticated? ? @user.name_with_handle : @user.handle
end
json.insts do
  json.array! @user.playings.published.count_insts do |inst, count|
    json.inst inst
    json.count count
  end
end
json.songs do
  json.array! @user.songs.published.order_by_live do |song|
    json.cache_if! !authenticated?, ['v1', song] do
      json.partial! 'api/v1/songs/song', song: song
      json.live song.live, partial: 'api/v1/lives/live', as: :live
    end
  end
end
