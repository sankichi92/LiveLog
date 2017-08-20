json.extract! song, :id, :name, :artist, :order
json.time song.time_str
json.youtube_id song.visible?(@current_user) ? song.youtube_id : ''
