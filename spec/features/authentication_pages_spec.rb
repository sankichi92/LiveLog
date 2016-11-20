require 'rails_helper'

RSpec.feature "AuthenticationPages", type: :feature do

  subject { page }

  scenario 'A user can see login page' do
    visit login_path

    is_expected.to have_content('Log in')
    is_expected.to have_title('Log in')
  end
end
