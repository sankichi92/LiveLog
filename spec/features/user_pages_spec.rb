require 'rails_helper'

RSpec.feature 'UserPages', type: :feature do
  given(:user) { create(:user) }
  given(:admin) { create(:admin) }

  feature 'Show members' do
    given(:users) do
      [create(:user, last_name: '山田', first_name: '花子', nickname: 'はな'),
       create(:user, last_name: 'Smith', first_name: 'John')]
    end
    background do
      live = create(:live, date: Time.zone.today)
      create(:song, live: live, users: users)
    end

    scenario 'A non-logged-in user can see the members page' do
      visit root_path
      click_link 'Members'

      expect(page).to have_title('Members')
      users.each do |user|
        expect(page).to have_content(user.handle)
        expect(page).not_to have_content(user.name_with_handle)
      end
    end

    scenario 'A logged-in user can see full name of all members in the members page' do
      log_in_as user
      visit users_path

      expect(page).to have_title('Members')
      users.each do |user|
        expect(page).to have_content(user.name_with_handle)
      end
    end

    scenario 'A user can see all members', js: true do
      visit users_path
      uncheck '1年以内にライブに出演したメンバーのみ表示'

      User.all.each do |user|
        expect(page).to have_content(user.handle)
        expect(page).not_to have_content(user.name_with_handle)
      end
    end
  end

  feature 'Profile page' do
    given(:song) { create(:song) }
    background do
      create(:playing, user: user, song: song)
      log_in_as user
    end

    scenario 'A user can see his/her profile page' do
      visit user_path(user)

      expect(page).to have_content(user.name_with_handle)
      expect(page).to have_title(user.name_with_handle)
      expect(page).to have_content(song.name)
    end
  end

  feature 'Add member' do
    background do
      log_in_as admin
      visit new_user_path
    end

    scenario 'An admin user cannot create a new user with invalid information' do
      expect { click_button 'Add' }.not_to change(User, :count)
      expect(page).to have_selector('.alert-danger')
    end

    scenario 'An admin user can create a new user with valid information' do
      fill_in '姓', with: '京大'
      fill_in '名', with: 'アンプラ太郎'
      fill_in 'ふりがな', with: 'きょうだいあんぷらたろう'
      select '2011', from: '入部年度'

      expect { click_button 'Add' }.to change(User, :count).by(1)
      expect(page).to have_selector('.alert-success')
    end
  end

  feature 'Edit his/her profile' do
    background do
      log_in_as user
      visit edit_user_path(user)
    end

    scenario 'A logged-in user can see the edit page' do
      expect(page).to have_content('Settings')
      expect(page).to have_title('Settings')
    end

    scenario 'A logged-in user cannot save changes with invalid information' do
      fill_in 'メールアドレス', with: ''
      click_button 'Save'

      expect(page).to have_selector('.alert-danger')
    end

    scenario 'A logged-in user can save changes with valid information' do
      new_nickname = 'New Nickname'
      new_email = 'new@ku-unplugged.net'

      fill_in 'ニックネーム', with: new_nickname
      fill_in 'メールアドレス', with: new_email
      click_button 'Save'

      expect(page).to have_selector('.alert-success')
      expect(user.reload.nickname).to eq new_nickname
      expect(user.reload.email).to eq new_email
    end
  end

  feature 'Delete user' do
    given(:not_activated_user) { create(:user, activated: false) }
    background do
      log_in_as admin
    end

    scenario 'An admin user can delete another user' do
      visit user_path(not_activated_user)

      expect { click_link('Delete', match: :first) }.to change(User, :count).by(-1)
    end
  end

  feature 'password edition' do

    scenario 'A non-logged-in user cannot visit a edit password page' do
      visit edit_user_password_path(user)

      expect(page).not_to have_title('Edit password')
      expect(page).to have_selector('.alert-danger')
    end

    scenario 'A logged-in user cannot visit other users edit password page' do
      log_in_as user
      visit edit_user_password_path(create(:user))

      expect(page).not_to have_title('Edit password')
    end

    scenario 'A logged-in user can edit his/her password with valid information' do
      new_password = 'new_password'
      log_in_as user
      visit edit_user_path(user)
      click_link 'パスワードを変更する'

      fill_in '現在のパスワード', with: user.password
      fill_in '新しいパスワード', with: new_password
      fill_in 'パスワードを再入力', with: new_password
      click_button 'Save'

      expect(page).to have_title(user.name_with_handle)
      expect(page).to have_selector('.alert-success')
    end

    scenario 'A logged-in user cannot edit his/her password with invalid information' do
      log_in_as user
      visit edit_user_password_path(user)

      click_button 'Save'

      expect(page).to have_title('Change Password')
      expect(page).to have_selector('.alert-danger')
    end

  end
end
