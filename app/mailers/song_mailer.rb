# frozen_string_literal: true

class SongMailer < ApplicationMailer
  def pickup(song = Song.pickup)
    @song = song
    emails = @song.members.joins(:user).includes(:user)
               .select { |m| m.user.auth0_user.email_verified_and_accepting? }
               .map { |m| %("#{m.name}" <#{m.user.auth0_user.email}>) }
    mail bcc: emails, subject: "「#{@song.name}」が今日のピックアップに選ばれました！" if emails.present?
  end
end
