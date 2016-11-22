require 'rails_helper'

RSpec.feature "PasswordResetPages", type: :feature do

  feature 'Send password reset email' do
    given(:user) { create(:user) }
    background do
      ActionMailer::Base.deliveries.clear
      visit new_password_reset_path
    end

    scenario 'A user cannot send email with invalid email' do
      click_button 'Submit'

      expect(page).to have_title('Forgot password')
      expect(page).to have_selector('.alert-danger')
    end

    scenario 'A user can send email with valid email' do
      fill_in 'Email', with: user.email
      click_button 'Submit'

      expect(user.reset_digest).not_to eq user.reload.reset_digest
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(page).to have_selector('.alert-info')
      expect(page).not_to have_title('Forgot password')
    end
  end

  feature 'Reset password' do
    given(:user) { create(:user) }
    background do
      user.reset_token = User.new_token
      user.reset_digest = User.digest(user.reset_token)
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

    scenario 'A user can change his/her password with valid information' do
      new_password = 'new_password'
      visit edit_password_reset_path(user.reset_token, email: user.email)

      expect(page).to have_title('Reset password')
      expect(find('#email', visible: false).value).to eq user.email

      fill_in '新しいパスワード', with: new_password
      fill_in 'パスワードを再入力', with: new_password
      click_button 'Update'

      expect(page).to have_content(user.full_name)
      expect(page).to have_selector('.alert-success')
    end

    scenario 'A user cannot change his/her password with invalid password' do
      visit edit_password_reset_path(user.reset_token, email: user.email)

      fill_in '新しいパスワード', with: 'foobar'
      fill_in 'パスワードを再入力', with: 'barquux'
      click_button 'Update'

      expect(page).to have_selector('.alert-danger')
    end

    scenario 'A user cannot change his/her password with invalid password' do
      visit edit_password_reset_path(user.reset_token, email: user.email)

      fill_in '新しいパスワード', with: 'foobar'
      fill_in 'パスワードを再入力', with: 'barquux'
      click_button 'Update'

      expect(page).to have_selector('.alert-danger')
    end

    scenario 'A user cannot change his/her password with empty password' do
      visit edit_password_reset_path(user.reset_token, email: user.email)

      fill_in '新しいパスワード', with: ''
      fill_in 'パスワードを再入力', with: ''
      click_button 'Update'

      expect(page).to have_selector('.alert-danger')
    end
  end
end
