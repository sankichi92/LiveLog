class EntryMailer < ApplicationMailer
  default to: '"PA" <pa@ku-unplugged.net>'

  def created(entry)
    @entry = entry
    from = %("#{entry.member.name}" <noreply@livelog.ku-unplugged.net>)
    bcc = if entry.member.user.auth0_user.email_verified?
            %("#{entry.member.name}" <#{entry.member.user.auth0_user.email}>)
          else
            nil
          end
    mail from: from, bcc: bcc, subject: "新規エントリー: #{entry.song.live.name}「#{entry.song.title}」"
  end
end
