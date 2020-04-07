require 'rails_helper'

RSpec.describe 'admin/users request:', type: :request do
  let(:admin) { create(:admin, scope: %w[write:members]) }

  before do
    log_in_as admin.user
  end

  describe 'DELETE /members/:member_id/user' do
    let(:user) { create(:user) }

    let(:auth0_client) { spy(:app_auth0_client) }

    before do
      allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)
    end

    it 'destroys the user and redirects to /admin/members' do
      delete admin_member_user_path(user.member)

      expect(auth0_client).to have_received(:delete_user).with(user.auth0_id)
      expect { user.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(response).to redirect_to admin_members_path(year: user.member.joined_year)
    end

    context 'when user has an administrator' do
      before do
        user.create_admin!
      end

      it 'redirects to /admin/members' do
        delete admin_member_user_path(user.member)

        expect(auth0_client).not_to have_received(:delete_user).with(user.auth0_id)
        expect(user.reload).to be_persisted
        expect(response).to redirect_to admin_members_path(year: user.member.joined_year)
      end
    end
  end
end
