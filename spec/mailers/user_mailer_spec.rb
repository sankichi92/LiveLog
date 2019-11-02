require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'account_activation' do
    let(:user) { create(:user) }
    let(:inviter) { create(:user) }
    let(:mail) { UserMailer.account_activation(user, inviter) }

    before { user.activation_token = 'token' }

    it 'renders the headers' do
      expect(mail.subject).to eq("#{inviter.name} さんが LiveLog に招待しています")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['noreply@livelog.ku-unplugged.net'])
    end

    it 'renders the text body' do
      expect(mail.text_part.body).to include(user.name)
      expect(mail.text_part.body).to include(user.activation_token)
    end

    it 'renders the html body' do
      expect(mail.html_part.body).to include(user.name)
      expect(mail.html_part.body).to include(user.activation_token)
    end
  end

  describe 'password_reset' do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.password_reset(user) }

    before { user.reset_token = 'token' }

    it 'renders the headers' do
      expect(mail.subject).to eq('パスワード再設定のご案内')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['noreply@livelog.ku-unplugged.net'])
    end

    it 'renders the text body' do
      expect(mail.text_part.body).to include(user.reset_token)
      expect(mail.text_part.body).to include(CGI.escape(user.email))
    end

    it 'renders the html body' do
      expect(mail.html_part.body).to include(user.reset_token)
      expect(mail.html_part.body).to include(CGI.escape(user.email))
    end
  end
end
