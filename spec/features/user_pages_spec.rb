require 'rails_helper'

RSpec.feature "UserPages", type: :feature do

  scenario 'A user can see the sign up page' do
    visit signup_path

    expect(page).to have_title(full_title('Sign up'))
    expect(page).to have_content('Sign up')
  end

  scenario 'A user can see his profile page' do
    user = create(:user)

    visit user_path(user)

    expect(page).to have_content(user.full_name)
    expect(page).to have_title(user.full_name)
  end

  feature 'Create a new user' do
    background do
      log_in_as create(:user)
      visit new_user_path
    end

    scenario 'A logged-in user cannot create a new user with invalid information' do
      expect { click_button 'Add' }.not_to change(User, :count)
      expect(page).to have_selector('.alert-danger')
    end

    scenario 'A logged-in user can create a new user with valid information' do
      fill_in '姓', with: '京大'
      fill_in '名', with: 'アンプラ太郎'
      fill_in 'ふりがな', with: 'きょうだいあんぷらたろう'
      select '2011', from: '入部年度'

      expect { click_button 'Add' }.to change(User, :count).by(1)
      expect(page).to have_selector('.alert-success')
    end
  end

  feature 'Edit his/her profile' do
    given(:user) { create(:user) }
    background do
      log_in_as user
      visit edit_user_path(user)
    end

    scenario 'A logged-in user can see the edit page' do
      expect(page).to have_content('Update your profile')
      expect(page).to have_title('Edit user')
    end

    scenario 'A logged-in user cannot save changes with invalid information' do
      fill_in 'パスワード', with: 'foo'
      fill_in 'パスワードを再入力', with: 'bar'
      click_button 'Save'

      expect(page).to have_selector('.alert-danger')
    end

    scenario 'A logged-in user can save changes with valid information' do
      new_nickname = 'New Nickname'
      new_email = 'new@ku-unplugged.net'

      fill_in 'ニックネーム', with: new_nickname
      fill_in 'メールアドレス', with: new_email
      fill_in 'パスワード', with: ''
      fill_in 'パスワードを再入力', with: ''
      click_button 'Save'

      expect(page).to have_selector('.alert-success')
      expect(user.reload.nickname).to eq new_nickname
      expect(user.reload.email).to eq new_email
    end
  end

  feature 'Index' do
    background do
      log_in_as create(:user)
      create(:user, first_name: 'Bob', email: 'bob@ku-unplugged.net')
      create(:user, first_name: 'Ben', email: 'ben@ku-unplugged.net')
      visit users_path
    end

    scenario 'A user can see the members page' do
      expect(page).to have_title('Members')
      expect(page).to have_content('Members')
      User.all.each do |user|
        expect(page).to have_selector('li', text: user.full_name)
      end
    end
  end
end
