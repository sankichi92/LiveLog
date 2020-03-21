class LiveMailer < ApplicationMailer
  def entries_backup(live)
    entries = Entry.includes(:playable_times).joins(:song).merge(Song.where(live_id: live.id)).order(:id)
    jsonl = entries.map { |entry| entry.as_json(include: { playable_times: { only: :range } }).to_json }.join("\n")
    attachments["live_#{live.id}_entries_#{Time.zone.today.to_s}.jsonl"] = jsonl
    mail to: 'miyoshi@ku-unplugged.net', subject: "[Entries backup] ID: #{live.id} #{live.title}"
  end
end
