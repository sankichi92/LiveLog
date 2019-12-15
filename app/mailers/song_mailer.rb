class SongMailer < ApplicationMailer
  def pickup_song(song = Song.pickup)
    @song = song
    emails = @song.members.joins(:user).includes(:user)
               .select { |m| m.user.auth0_user.email_verified? && m.user.auth0_user.subscribing? }
               .map { |m| %("#{m.name}" <#{m.user.auth0_user.email}>) }
    mail bcc: emails, subject: "「#{@song.name}」が今日のピックアップに選ばれました！" if emails.present?
  end
end
