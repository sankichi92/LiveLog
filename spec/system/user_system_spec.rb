require 'rails_helper'

RSpec.describe 'User', type: :system do
  describe 'edit' do
    let(:user) { create(:user, email: 'before@example.com') }

    before { log_in_as user }

    it 'enables users to update their own profile' do
      visit edit_user_path(user)

      expect(page).to have_title('メールアドレス設定')

      fill_in 'user_email', with: 'after@example.com'
      click_button '更新する'

      expect(page).to have_css('.alert-info')
      expect(user.reload.email).to eq 'after@example.com'
    end
  end
end
