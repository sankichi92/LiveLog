class SongMailer < ApplicationMailer
  default to: '"PA" <pa@ku-unplugged.net>'

  def entry(song, applicant)
    @song = song
    @applicant = applicant
    reply_to = %("#{applicant.name}" <#{applicant.email}>)
    from = %("#{applicant.name}" <noreply@livelog.ku-unplugged.net>)
    mail from: from, reply_to: reply_to, subject: "#{song.live_name} 曲申請「#{song.title}」"
  end
end
