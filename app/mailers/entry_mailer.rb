class EntryMailer < ApplicationMailer
  default to: '"PA" <pa@ku-unplugged.net>'

  def entry(entry)
    @entry = entry
    reply_to = %("#{entry.applicant_name}" <#{entry.applicant_email}>)
    from = %("#{entry.applicant_name}" <noreply@livelog.ku-unplugged.net>)
    mail from: from, reply_to: reply_to, subject: "#{entry.live_name} 曲申請「#{entry.title}」"
  end
end
