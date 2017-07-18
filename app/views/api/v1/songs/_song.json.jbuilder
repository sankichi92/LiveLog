json.extract! song, :id, :name, :artist, :order
json.time song.time_str
json.youtube_id can_watch?(song) ? song.youtube_id : ''
