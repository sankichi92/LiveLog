class SongMailer < ApplicationMailer
  def pickup_song(song = Song.pickup)
    @song = song
    emails = @song.playings.includes(:user).select { |p| p.user.enable_to_send_info? }.map { |p| %("#{p.user.name}" <#{p.user.email}>) }
    mail bcc: emails, subject: "「#{@song.name}」が今日のピックアップに選ばれました！" if emails.present?
  end
end
