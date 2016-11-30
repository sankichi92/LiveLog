require 'rails_helper'

RSpec.feature "UserPages", type: :feature do

  given(:user) { create(:user) }
  given(:admin) { create(:admin) }

  feature 'Show members' do
    background do
      log_in_as user
      create(:user, first_name: 'Bob', email: 'bob@ku-unplugged.net')
      create(:user, first_name: 'Ben', email: 'ben@ku-unplugged.net')
      visit users_path
    end

    scenario 'A logged-in user can see the members page' do
      expect(page).to have_title('Members')
      expect(page).to have_content('Members')
      User.all.each do |user|
        expect(page).to have_selector('li', text: user.full_name)
      end
    end

    scenario 'A logged-in user cannot see delete link' do
      expect(page).not_to have_selector('.glyphicon-trash')
    end

    context 'Admin user' do
      background do
        log_in_as admin
        visit users_path
      end

      xscenario 'An admin user can delete another user' do # TODO: Find how to click glyphicon
        expect { click_link('×', match: :first) }.to change(User, :count).by(-1)
      end

      xscenario 'An admin user cannot delete him/herself' do
        expect(page).not_to have_link('×', href: user_path(admin))
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

      expect(page).to have_content(user.full_name)
      expect(page).to have_title(user.full_name)
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
      expect(page).to have_content('Update your profile')
      expect(page).to have_title('Edit user')
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

      expect(page).to have_title(user.full_name)
      expect(page).to have_selector('.alert-success')
    end

    scenario 'A logged-in user cannot edit his/her password with invalid information' do
      log_in_as user
      visit edit_user_password_path(user)

      click_button 'Save'

      expect(page).to have_title('Edit password')
      expect(page).to have_selector('.alert-danger')
    end

  end
end
