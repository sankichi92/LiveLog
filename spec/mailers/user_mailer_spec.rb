require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'account_activation' do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.account_activation(user) }
    before { user.activation_token = User.new_token }

    it 'renders the headers' do
      expect(mail.subject).to eq('【LiveLog】アカウントの有効化')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['noreply@livelog.ku-unplugged.net'])
    end

    xit 'renders the body' do # TODO: Solve encoding of Japanese mail
      expect(mail.body.encoded).to match(user.full_name)
      expect(mail.body.encoded).to match(user.activation_token)
      expect(mail.body.encoded).to match(CGI.escape(user.email))
    end
  end

  xdescribe 'password_reset' do
    let(:mail) { UserMailer.password_reset }

    it 'renders the headers' do
      expect(mail.subject).to eq('Password reset')
      expect(mail.to).to eq(['to@example.org'])
      expect(mail.from).to eq(['from@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Hi')
    end
  end

end
