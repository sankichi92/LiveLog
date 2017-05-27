json.partial! 'users/user', user: @user
json.songs do
  json.array! @user.songs.order_by_live do |song|
    json.partial! 'songs/song', song: song
    json.live song.live, partial: 'lives/live', as: :live
  end
end
