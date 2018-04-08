json.extract! song, :id, :name, :artist, :order
json.time song.time_str
json.youtube_id policy(song).play? ? song.youtube_id : ''
