class EntryMailer < ApplicationMailer
  default to: '"PA" <pa@ku-unplugged.net>'

  def entry(entry)
    @entry = entry
    reply_to = %("#{entry.applicant_name}" <#{entry.applicant_email}>)
    from = %("#{entry.applicant_name}" <noreply@livelog.ku-unplugged.net>)
    cc = %("#{entry.applicant_name}" <#{entry.applicant_email}>)
    mail from: from, cc: cc, reply_to: reply_to, subject: "#{entry.live_name} 曲申請「#{entry.title}」"
  end
end
