require 'rails_helper'

RSpec.describe 'Omniauth', type: :system do
  describe 'Google OAuth 2' do
    let(:user) { create(:user) }

    before do
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(Faker::Omniauth.google)
    end

    it 'enables existing users connect their Google accounts and login by it' do
      log_in_as user

      visit edit_user_path(user)
      click_link 'Google アカウントと紐付ける'
      expect(page).to have_content '紐付けました'

      click_link 'Log out'
      visit login_path
      find('.btn-google-signin').click
      expect(page).to have_content 'ログインしました'

      visit edit_user_path(user)
      click_link 'Google アカウントとの紐付けを解除する'
      expect(page).to have_content 'Google アカウントとの紐付けを解除しました'
    end
  end
end
