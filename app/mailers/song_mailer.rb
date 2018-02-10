class SongMailer < ApplicationMailer
  default to: 'sankichi92@ku-unplugged.net'
  default reply_to: 'sankichi92@ku-unplugged.net'

  def pickup_song
    @song = Song.pickup
    emails = @song.playings.select { |p| p.email.present? }.map { |p| %("#{p.name}" <#{p.email}>) }
    mail bcc: emails, subject: "「#{@song.name}」が今日のピックアップに選ばれました！" if emails.present?
  end
end
