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

  context 'when creating a new user' do
    background { visit new_user_path }
    given(:submit) { 'Add' }

    scenario 'A user cannot create a new user with invalid information' do
      expect { click_button submit }.not_to change(User, :count)
      expect(page).to have_selector('.alert-danger')
    end

    scenario 'A user can create a new user with valid information' do
      fill_in '姓', with: '京大'
      fill_in '名', with: 'アンプラ太郎'
      fill_in 'ふりがな', with: 'きょうだいあんぷらたろう'
      select '2011', from: '入部年度'

      expect { click_button submit }.to change(User, :count).by(1)
      expect(page).to have_selector('.alert-success')
    end
  end

  context 'when editing his/her profile' do
    given(:user) { create(:user) }
    background { visit edit_user_path(user) }

    scenario 'A user can see the edit page' do
      expect(page).to have_content('Update your profile')
      expect(page).to have_title('Edit user')
    end

    scenario 'A user cannot save changes with invalid information' do
      click_button 'Save'

      expect(page).to have_selector('.alert-danger')
    end
  end
end
