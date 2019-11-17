require 'rails_helper'

RSpec.describe 'Account activation', type: :system do
  let(:inviter) { create(:user) }
  let(:user) { create(:user, :inactivated) }
  let(:email) { 'activation@example.com' }
  let(:password) { 'password' }
  let(:token) { 'token' }

  before do
    ActionMailer::Base.deliveries.clear
    allow(SecureRandom).to receive(:base64) { token }
  end

  it 'enables users to activate their account' do
    Capybara.using_session("Inviter's session") do
      log_in_as inviter

      # TODO
      # visit member_path(member)
      # click_link '招待する'
      visit new_user_activation_path(user)

      expect(page).to have_title('Invite')

      fill_in 'user_email', with: email
      click_button '送信する'

      expect(page).to have_css('.alert-success')
      expect(user.reload.email).to eq email
      expect(ActionMailer::Base.deliveries.size).to eq 1
    end

    visit edit_user_activation_path(user, t: token)

    expect(page).to have_title('Activation')

    fill_in 'user_password', with: password
    fill_in 'user_password_confirmation', with: password
    click_button 'アカウントを有効化する'

    expect(page).to have_css('.alert-success')
    expect(page).to have_content(user.member.full_name)
    expect(user.password_digest).not_to eq user.reload.password_digest
    expect(user.activated).to be true
  end
end
