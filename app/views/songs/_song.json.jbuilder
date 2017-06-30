json.extract! song, :id, :name, :artist, :order, :time, :status
json.youtube_id song.open? ? song.youtube_id : ''
