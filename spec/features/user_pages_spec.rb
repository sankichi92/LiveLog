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

    scenario 'A logged in user cannot create a new user with invalid information' do
      expect { click_button submit }.not_to change(User, :count)
      expect(page).to have_content('error')
    end

    scenario 'A logged in user can create a new user with valid information' do
      fill_in 'Last name', with: '京大'
      fill_in 'First name', with: 'アンプラ太郎'
      fill_in 'Furigana', with: 'きょうだいあんぷらたろう'
      select '2011', from: 'Joined'

      expect { click_button submit }.to change(User, :count).by(1)
      expect(page).to have_selector '.alert-success'
    end
  end
end
