class SongMailer < ApplicationMailer
  default to: '"PA" <pa@ku-unplugged.net>'

  def entry(song, applicant)
    @song = song
    @applicant = applicant
    email_with_name = %("#{applicant.formal_name}" <#{applicant.email}>)
    mail reply_to: email_with_name, subject: "#{song.live.name} 曲申請「#{song.title}」"
  end
end
