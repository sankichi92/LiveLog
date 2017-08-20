require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'account_activation' do
    let(:user) { create(:user) }
    let(:inviter) { create(:user) }
    let(:mail) { UserMailer.account_activation(user, inviter) }

    before { user.activation_token = Token.random }

    it 'renders the headers' do
      expect(mail.subject).to eq("#{inviter.formal_name} さんが LiveLog に招待しています")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['noreply@livelog.ku-unplugged.net'])
      expect(mail.reply_to).to eq(['miyoshi@ku-unplugged.net'])
    end

    it 'renders the text body' do
      expect(mail.text_part.body).to match(user.full_name)
      expect(mail.text_part.body).to match(user.activation_token)
    end

    it 'renders the html body' do
      expect(mail.html_part.body).to match(user.full_name)
      expect(mail.html_part.body).to match(user.activation_token)
    end
  end

  describe 'password_reset' do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.password_reset(user) }
    before { user.reset_token = Token.random }

    it 'renders the headers' do
      expect(mail.subject).to eq('パスワード再設定のご案内')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['noreply@livelog.ku-unplugged.net'])
      expect(mail.reply_to).to eq(['miyoshi@ku-unplugged.net'])
    end

    it 'renders the text body' do
      expect(mail.text_part.body).to match(user.reset_token)
      expect(mail.text_part.body).to match(CGI.escape(user.email))
    end

    it 'renders the html body' do
      expect(mail.html_part.body).to match(user.reset_token)
      expect(mail.html_part.body).to match(CGI.escape(user.email))
    end
  end

end
