require 'rails_helper'

RSpec.describe 'Password reset', type: :system do
  let(:user) { create(:user) }
  let!(:token) { 'token' }

  before do
    ActionMailer::Base.deliveries.clear
    allow(SecureRandom).to receive(:base64) { token }
  end

  it 'enable users to reset password' do
    visit login_path
    click_link 'パスワードを忘れた場合'

    expect(page).to have_title('Forgot Password')

    fill_in 'password_reset_email', with: user.email
    click_button '送信する'

    expect(ActionMailer::Base.deliveries.size).to eq 1
    expect(page).to have_css('.alert-success')

    visit edit_password_reset_path(token, email: user.email)

    expect(page).to have_title('Reset Password')

    fill_in 'user_password', with: 'new_password'
    fill_in 'user_password_confirmation', with: 'new_password'
    click_button '更新する'

    expect(user.password_digest).not_to eq user.reload.password_digest
    expect(page).to have_css('.alert-success')
  end
end
