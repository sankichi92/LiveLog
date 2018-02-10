# Preview all emails at http://localhost:3000/rails/mailers/song_mailer
class SongMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/song_mailer/pickup_song
  def pickup_song
    song = Song.pickup
    SongMailer.pickup_song(song)
  end
end
