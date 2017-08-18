class SongMailer < ApplicationMailer
  default to: 'pa@ku-unplugged.net'

  def entry(song, applicant, notes)
    @song = song
    @applicant = applicant
    @notes = notes
    email_with_name = %("#{applicant.formal_name}" <#{applicant.email}>)
    mail from: email_with_name, subject: "#{song.live.title} 曲申請「#{song.title}」"
  end
end
