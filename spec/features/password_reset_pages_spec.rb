require 'rails_helper'

RSpec.feature 'PasswordResetPages', type: :feature do

  feature 'Send password reset email' do
    given(:user) { create(:user) }
    given(:not_activated_user) { create(:user, activated: false) }
    background do
      ActionMailer::Base.deliveries.clear
      visit new_password_reset_path
    end

    scenario 'A user cannot send email with invalid email' do
      click_button 'Send'

      expect(page).to have_title('Forgot Password')
      expect(page).to have_selector('.alert-danger')
    end

    scenario 'A user can send email with valid email' do
      fill_in 'Email', with: user.email
      click_button 'Send'

      expect(user.reset_digest).not_to eq user.reload.reset_digest
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(page).to have_selector('.alert-success')
      expect(page).not_to have_title('Forgot Password')
    end

    scenario 'A not activated user cannot send email' do
      fill_in 'Email', with: not_activated_user.email
      click_button 'Send'

      expect(page).to have_title('Forgot Password')
      expect(page).to have_selector('.alert-warning')
    end
  end

  feature 'Reset password' do
    given(:user) { create(:user) }
    background do
      user.reset_token = Token.random
      user.reset_digest = Token.digest(user.reset_token)
      user.reset_sent_at = Time.zone.now
      user.save
    end

    scenario 'A user cannot see the password reset page with wrong email' do
      visit edit_password_reset_path(user.reset_token, email: '')

      expect(page).not_to have_title('Reset password')
    end

    scenario 'An inactivated user cannot see the password reset page' do
      user.toggle!(:activated)
      visit edit_password_reset_path(user.reset_token, email: user.email)

      expect(page).not_to have_title('Reset password')
    end

    scenario 'A user cannot see the password reset page with wrong token' do
      visit edit_password_reset_path('wrong token', email: user.email)

      expect(page).not_to have_title('Reset password')
    end

    scenario 'A user cannot see the password reset page sith expired token' do
      user.update_attribute(:reset_sent_at, 3.hours.ago)
      visit edit_password_reset_path(user.reset_token, email: user.email)

      expect(page).not_to have_title('Reset Password')
    end

    scenario 'A user can change his/her password with valid information' do
      new_password = 'new_password'
      visit edit_password_reset_path(user.reset_token, email: user.email)

      expect(page).to have_title('Reset Password')
      expect(find('#email', visible: false).value).to eq user.email

      fill_in '新しいパスワード', with: new_password
      fill_in 'パスワードを再入力', with: new_password
      click_button 'Save'

      expect(page).to have_content(user.name_with_handle)
      expect(page).to have_selector('.alert-success')
    end

    scenario 'A user cannot change his/her password with invalid password' do
      visit edit_password_reset_path(user.reset_token, email: user.email)

      fill_in '新しいパスワード', with: 'foobar'
      fill_in 'パスワードを再入力', with: 'barquux'
      click_button 'Save'

      expect(page).to have_selector('.alert-danger')
    end

    scenario 'A user cannot change his/her password with invalid password' do
      visit edit_password_reset_path(user.reset_token, email: user.email)

      fill_in '新しいパスワード', with: 'foobar'
      fill_in 'パスワードを再入力', with: 'barquux'
      click_button 'Save'

      expect(page).to have_selector('.alert-danger')
    end

    scenario 'A user cannot change his/her password with empty password' do
      visit edit_password_reset_path(user.reset_token, email: user.email)

      fill_in '新しいパスワード', with: ''
      fill_in 'パスワードを再入力', with: ''
      click_button 'Save'

      expect(page).to have_selector('.alert-danger')
    end
  end
end
