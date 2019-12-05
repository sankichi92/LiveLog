class EntryMailer < ApplicationMailer
  default to: '"PA" <pa@ku-unplugged.net>'

  def entry(entry)
    @entry = entry
    from = %("#{entry.applicant.member.name}" <noreply@livelog.ku-unplugged.net>)
    cc = %("#{entry.applicant.member.name}" <#{entry.applicant.auth0_user.email}>)
    mail from: from, cc: cc, subject: "#{entry.live.name} 曲申請「#{entry.title}」"
  end
end
