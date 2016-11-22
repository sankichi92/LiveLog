require 'rails_helper'

RSpec.feature "UserPages", type: :feature do

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

    scenario 'A user cannot see delete link' do
      expect(page).not_to have_link('×')
    end

    context 'Admin user' do
      given(:admin) { create(:admin) }
      background do
        log_in_as admin
        visit users_path
      end

      scenario 'An admin user delete another user' do
        expect { click_link('×', match: :first) }.to change(User, :count).by(-1)
      end

      scenario 'An admin user cannot delete him/herself' do
        expect(page).not_to have_link('×', href: user_path(admin))
      end
    end
  end

  feature 'Profile page' do
    given(:user) { create(:user) }
    background { log_in_as user }

    scenario 'A user can see his/her profile page' do
      visit user_path(user)

      expect(page).to have_content(user.full_name)
      expect(page).to have_title(user.full_name)
    end
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

  feature 'Invitation' do
    given(:user) { create(:user) }
    given(:not_activated_user) { create(:user, email: nil, activated: false) }

    scenario 'A non-logged-in user cannot see an invitation page' do
      visit new_user_activations_path(not_activated_user)
      expect(page).not_to have_title('Invite')
    end

    scenario 'A logged-in user can invite an not_activated user' do
      new_email = 'not_activated@ku-unplugged.net'

      log_in_as user
      visit new_user_activations_path(not_activated_user)

      expect(page).to have_title('Invite')

      fill_in 'メールアドレス', with: new_email
      click_button 'Invite'

      expect(not_activated_user.reload.email).to eq new_email
      expect(page).to have_selector('.alert-success')
      expect(page).to have_title('Members')
    end

    scenario 'A logged-in user cannot invite with invalid email' do
      log_in_as user
      visit new_user_activations_path(not_activated_user)

      fill_in 'メールアドレス', with: ''
      click_button 'Invite'

      expect(page).to have_selector('.alert-danger')
      expect(page).not_to have_title('Members')
    end

    scenario 'A logged-in user cannot invite an activated user' do
      log_in_as user
      visit new_user_activations_path(create(:user))

      expect(page).not_to have_title('Invite')
    end
  end

  feature 'Activation' do
    given(:user) { create(:user, activated: false) }
    given(:token) { User.new_token }
    background do
      user.activation_digest = User.digest(token)
      user.save
    end

    scenario 'A user can activate his/her account with valid information' do
      password = 'new_password'
      visit edit_user_activations_path(user, t: token)

      expect(page).to have_title('Activation')

      fill_in 'パスワードを作成', with: password
      fill_in 'パスワードを再入力', with: password
      click_button 'Activate'

      expect(page).to have_selector('.alert-success')
      expect(page).to have_title(user.full_name)
    end

    scenario 'A user cannot activate his/her account with invalid token' do
      visit edit_user_activations_path(user, t: 'invalid_token')

      expect(page).to have_selector('.alert-danger')
      expect(page).not_to have_title('Activation')
    end

    scenario 'A user cannot activate other users account' do
      another_user = create(:user, activated: false)
      visit edit_user_activations_path(another_user, t: 'invalid_token')

      expect(page).to have_selector('.alert-danger')
      expect(page).not_to have_title('Activation')
    end

    scenario 'A user cannot activate his/her account with invalid password' do
      password = ''
      visit edit_user_activations_path(user, t: token)

      fill_in 'パスワードを作成', with: password
      fill_in 'パスワードを再入力', with: password
      click_button 'Activate'

      expect(page).to have_selector('.alert-danger')
      expect(page).not_to have_title(user.full_name)
    end
  end
end
