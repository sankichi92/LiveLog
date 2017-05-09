json.partial! 'songs/song', song: @song
json.playings @song.playings, partial: 'playings/playing', as: :playing
