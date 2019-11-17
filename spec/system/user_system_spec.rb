require 'rails_helper'

RSpec.describe 'User', type: :system do
  describe 'edit' do
    let(:user) { create(:user, email: 'before@example.com') }

    before { log_in_as user }

    it 'enables users to update their own profile' do
      visit edit_user_path(user)

      expect(page).to have_title('Settings')

      fill_in 'user_email', with: 'after@example.com'
      click_button '更新する'

      expect(page).to have_css('.alert-success')
      expect(user.reload.email).to eq 'after@example.com'
    end
  end

  describe 'edit password' do
    let(:user) { create(:user) }

    before { log_in_as user }

    it 'enables users to update their own password' do
      visit edit_user_path(user)
      click_link 'パスワードを変更する'

      expect(page).to have_title('Change Password')

      fill_in 'current_password', with: user.password
      fill_in 'user_password', with: 'new_password'
      fill_in 'user_password_confirmation', with: 'new_password'
      click_button '更新する'

      expect(user.password_digest).not_to eq user.reload.password_digest
      expect(page).to have_css('.alert-success')
      expect(page).to have_content(user.member.full_name)
    end
  end
end
