require 'rails_helper'

RSpec.describe "Authentication", type: :request do

  describe 'for non-signed-in users' do
    let(:user) { create(:user) }

    describe 'in the Users controller' do

      describe 'visiting the edit page' do
        before { get edit_user_path(user) }
        specify { expect(response).to redirect_to(login_path) }
      end

      describe 'submitting to the update action' do
        before { patch user_path(user) }
        specify { expect(response).to redirect_to(login_path) }
      end
    end
  end

  describe 'as wrong user' do
    let(:user) { create(:user) }
    let(:wrong_user) { create(:user, email: 'wrong@example.com') }
    before { log_in_as user, capybara: false }

    describe 'submitting a GET request to the Users#edit action' do
      before { get edit_user_path(wrong_user) }
      specify { expect(response.body).not_to match(full_title('Edit user')) }
      specify { expect(response).to redirect_to(root_url) }
    end

    describe 'submitting a PATCH request to the Users#update action' do
      before { patch user_path(wrong_user) }
      specify { expect(response).to redirect_to(root_path) }
    end
  end

  describe 'as non-admin user' do
    let(:user) { create(:user) }
    let(:non_admin) { create(:user) }

    before { log_in_as non_admin, capybara: false }

    describe 'submitting a DELETE request to the Users#destroy action' do
      before { delete user_path(user) }
      specify { expect(response).to redirect_to(root_path)}
    end
  end
end
