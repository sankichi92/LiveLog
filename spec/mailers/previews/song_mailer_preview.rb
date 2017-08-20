# Preview all emails at http://localhost:3000/rails/mailers/song_mailer
class SongMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/song_mailer/entry
  def entry
    applicant = User.first
    song = applicant.songs.last
    song.notes = 'Vo がタンバリンを使うかもしれません'
    SongMailer.entry(song, applicant)
  end
end
