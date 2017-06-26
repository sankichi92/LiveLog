json.extract! song, :id, :name, :artist, :order, :time, :status
json.have_video song.youtube_id.present?
