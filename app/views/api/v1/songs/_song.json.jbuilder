json.extract! song, :id, :name, :artist, :order
json.time song.time_str
json.youtube_id policy(song).watch? ? song.youtube_id : ''
