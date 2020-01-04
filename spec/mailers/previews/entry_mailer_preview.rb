# Preview all emails at http://localhost:3000/rails/mailers/entry_mailer
class EntryMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/entry_mailer/created
  def created
    EntryMailer.created(Entry.includes(song: { plays: :member }).last || FactoryBot.create(:entry))
  end
end
