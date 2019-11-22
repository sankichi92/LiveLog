class SongMailer < ApplicationMailer
  def pickup_song(song = Song.pickup)
    @song = song
    emails = @song.members.joins(:user).includes(:user).select { |m| m.user.enable_to_send_info? }.map { |m| %("#{m.name}" <#{m.user.email}>) }
    mail bcc: emails, subject: "「#{@song.name}」が今日のピックアップに選ばれました！" if emails.present?
  end
end
