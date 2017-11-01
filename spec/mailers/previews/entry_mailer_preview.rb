# Preview all emails at http://localhost:3000/rails/mailers/entry_mailer
class EntryMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/entry_mailer/entry
  def entry
    applicant = User.first
    song = applicant.songs.last
    entry = Entry.new(
      applicant: applicant,
      song: song,
      preferred_rehearsal_time: '〜20:00,22:30〜25:00',
      preferred_performance_time: '19:00〜20:30,23:00〜',
      notes: 'Vo がタンバリンを使うかもしれません'
    )
    EntryMailer.entry(entry)
  end
end
