require 'rails_helper'

RSpec.feature "ActivationPages", type: :feature do

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
