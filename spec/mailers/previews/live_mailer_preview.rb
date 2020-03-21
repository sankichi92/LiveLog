# Preview all emails at http://localhost:3000/rails/mailers/live
class LiveMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/live_mailer/entries_backup
  def entries_backup
    LiveMailer.entries_backup(Live.joins(songs: :entry).unpublished.last)
  end
end
