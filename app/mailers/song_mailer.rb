class SongMailer < ApplicationMailer
  default to: 'sankichi92@ku-unplugged.net'

  def pickup_song(song = Song.pickup)
    @song = song
    emails = @song.playings.select { |p| p.user.enable_to_send_info? }.map { |p| %("#{p.name}" <#{p.email}>) }
    mail bcc: emails, subject: "「#{@song.name}」が今日のピックアップに選ばれました！" if emails.present?
  end
end
