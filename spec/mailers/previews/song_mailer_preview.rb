# Preview all emails at http://localhost:3000/rails/mailers/song_mailer
class SongMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/song_mailer/pickup_song
  def pickup_song
    SongMailer.pickup_song
  end
end
