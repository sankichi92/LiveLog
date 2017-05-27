json.partial! 'songs/song', song: @song
json.live @song.live, partial: 'lives/live', as: :live
json.playings @song.playings, partial: 'playings/playing', as: :playing
