class SongMailer < ApplicationMailer
  default to: '"PA" <pa@ku-unplugged.net>'

  def entry(song, applicant)
    @song = song
    @applicant = applicant
    email_with_name = %("#{applicant.name}" <#{applicant.email}>)
    from_with_name = %("#{applicant.name}" <noreply@livelog.ku-unplugged.net>)
    mail from: from_with_name, reply_to: email_with_name, subject: "#{song.live_name} 曲申請「#{song.title}」"
  end
end
