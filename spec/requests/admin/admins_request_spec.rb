require 'rails_helper'

RSpec.describe 'admin/admins requests:', type: :request do
  let(:admin) { create(:admin) }

  before do
    log_in_as admin
  end

  describe 'POST /members/:member_id/admin' do
    let(:user) { create(:user) }

    it 'makes the user admin and redirects to /admin/members' do
      post admin_member_admin_path(user.member)

      expect(user.reload).to be_admin
      expect(response).to redirect_to admin_members_path(year: user.member.joined_year)
    end
  end

  describe 'DELETE /members/:member_id/admin' do
    let(:user) { create(:user) }

    it 'destroys the user and redirects to /admin/members' do
      delete admin_member_admin_path(user.member)

      expect(user.reload).not_to be_admin
      expect(response).to redirect_to admin_members_path(year: user.member.joined_year)
    end
  end
end
