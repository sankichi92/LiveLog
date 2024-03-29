# frozen_string_literal: true

class LiveMailer < ApplicationMailer
  def entries_backup(live)
    @entry_guideline = live.entry_guideline

    entries = Entry.includes(:playable_times).joins(:song).merge(Song.where(live_id: live.id)).order(:id)
    jsonl = entries.map { |entry| entry.as_json(include: { playable_times: { only: :range } }).to_json }.join("\n")

    attachments["live_#{live.id}_entries_#{Time.zone.today}.jsonl"] = jsonl
    mail to: 'takahiro-miyoshi+livelog@sankichi.net', subject: "[Entries backup] ID: #{live.id} #{live.name}"
  end
end
