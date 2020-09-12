require 'rails_helper'

RSpec.describe LiveMailer, type: :mailer do
  describe '#entries_backup' do
    subject(:mail) { LiveMailer.entries_backup(live) }

    let(:live) { create(:live, :unpublished, :with_entry_guideline, :with_entries) }

    it 'renders the headers and attaches a file' do
      expect(mail.from).to contain_exactly 'noreply@livelog.ku-unplugged.net'
      expect(mail.to).to contain_exactly 'miyoshi@ku-unplugged.net'
      expect(mail.subject).to be_start_with '[Entries backup]'
      expect(mail.attachments.size).to eq 1
      expect(mail.attachments.first.filename).to be_start_with "live_#{live.id}_entries_"
      expect(mail.attachments.first.body).to be_present
      expect(mail.text_part.body.to_s).to be_present
    end
  end
end
