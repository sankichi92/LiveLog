json.extract! song, :id, :name, :artist, :order
json.time song.time_str
json.youtube_id song.open? ? song.youtube_id : ''
