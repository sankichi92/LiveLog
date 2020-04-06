require 'rails_helper'

RSpec.describe 'admin/admins request:', type: :request do
  let(:admin) { create(:admin) }

  before do
    log_in_as admin.user
  end

  describe 'POST /members/:member_id/admin' do
    let(:user) { create(:user) }

    it 'makes the user admin and redirects to /admin/members' do
      post admin_member_admin_path(user.member)

      expect(user.admin).to be_persisted
      expect(response).to redirect_to admin_members_path(year: user.member.joined_year)
    end
  end

  describe 'DELETE /members/:member_id/admin' do
    let(:admin) { create(:admin) }

    it 'destroys the user and redirects to /admin/members' do
      delete admin_member_admin_path(admin.user.member)

      expect { admin.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(response).to redirect_to admin_members_path(year: admin.user.member.joined_year)
    end
  end
end
