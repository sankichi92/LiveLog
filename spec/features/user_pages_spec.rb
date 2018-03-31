require 'rails_helper'

RSpec.feature 'UserPages', type: :feature do
  feature 'password edition' do
    given(:user) { create(:user) }
    given(:admin) { create(:admin) }

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
