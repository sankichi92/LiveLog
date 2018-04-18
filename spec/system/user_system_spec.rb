require 'rails_helper'

RSpec.describe 'User', type: :system do
  describe 'list' do
    before do
      create_list(:user, 5, joined: 2018, public: true)
      create_list(:user, 5, joined: 2017, public: true)
    end

    it 'enables users to see the member list for each year' do
      visit users_path

      expect(page).to have_title('Members')
      expect(page).to have_content('Members')
      User.where(joined: 2018).each do |user|
        expect(page).to have_content(user.handle)
      end

      click_on '2017'

      User.where(joined: 2017).each do |user|
        expect(page).to have_content(user.handle)
      end
    end
  end

  describe 'detail' do
    let(:user) { create(:user, public: true) }

    it 'enables non-admin users to see individual member pages' do
      visit user_path(user)

      expect(page).to have_title(user.handle)
      expect(page).to have_content(user.handle)
      expect(page).to have_content(user.joined)
      expect(page).not_to have_css('#admin-tools')
      user.songs.each do |song|
        expect(page).to have_content(song.name)
      end
    end

    it 'enables admin users to see individual member pages with admin tools' do
      log_in_as create(:admin)

      visit user_path(user)

      expect(page).to have_title(user.name_with_handle)
      expect(page).to have_content(user.name_with_handle)
      expect(page).to have_css('#admin-tools')
    end
  end

  describe 'add' do
    before { log_in_as create(:admin) }

    it 'enables admin users to create new lives' do
      visit root_path
      click_link 'New Member'

      expect(page).to have_title('New Member')

      fill_in 'user_last_name', with: '京大'
      fill_in 'user_first_name', with: 'アンプラ太郎'
      fill_in 'user_furigana', with: 'きょうだいあんぷらたろう'
      select '2011', from: 'user_joined'

      expect { click_button t('helpers.submit.create') }.to change(User, :count).by(1)
      expect(page).to have_css('.alert-success')
      expect(page).to have_title('New Member')
    end
  end

  describe 'edit' do
    let(:user) { create(:user) }

    before { log_in_as user }

    it 'enables users to update their own profile' do
      visit edit_user_path(user)

      expect(page).to have_title('Settings')

      fill_in 'user_nickname', with: 'アンプラ'
      click_button t('helpers.submit.update')

      expect(user.reload.nickname).to eq 'アンプラ'
      expect(page).to have_css('.alert-success')
      expect(page).to have_title(user.name_with_handle)
    end
  end

  describe 'delete' do
    let(:user) { create(:user) }

    before { log_in_as create(:admin) }

    it 'enables admin users to delete users' do
      visit user_path(user)

      click_link('アカウントを無効にする')

      expect(page).to have_css('.alert-success')
      expect(user.reload.activated).to be false

      expect { click_link(t('views.application.delete')) }.to change(User, :count).by(-1)
      expect(page).to have_css('.alert-success')
    end
  end

  describe 'edit password' do
    let(:user) { create(:user) }

    before { log_in_as user }

    it 'enables users to update their own password' do
      visit edit_user_path(user)
      click_link t('views.users.change_password')

      expect(page).to have_title('Change Password')

      fill_in 'current_password', with: user.password
      fill_in 'user_password', with: 'new_password'
      fill_in 'user_password_confirmation', with: 'new_password'
      click_button t('helpers.submit.update')

      expect(user.password_digest).not_to eq user.reload.password_digest
      expect(page).to have_css('.alert-success')
      expect(page).to have_title(user.name_with_handle)
    end
  end

  describe 'make admin' do
    let(:user) { create(:user)}

    before { log_in_as create(:admin) }

    it 'enables admin users to make users admin' do
      visit user_path(user)

      click_link '管理者にする'

      expect(user.reload.admin).to be true

      click_link '管理者権限を無効にする'

      expect(user.reload.admin).to be false
    end
  end
end
