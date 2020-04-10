require 'rails_helper'

RSpec.describe 'admin/admins request:', type: :request do
  let(:admin) { create(:admin, scopes: %w[write:admins]) }

  before do
    log_in_as admin.user
  end

  describe 'GET /admin/administrators' do
    before do
      create_pair(:admin)
    end

    it 'responds 200' do
      get admin_administrators_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'POST /admin/members/:member_id/admin' do
    let(:user) { create(:user) }

    it 'makes the user admin and redirects to /admin/administrators' do
      post admin_member_administrator_path(user.member)

      expect(user.admin).to be_persisted
      expect(response).to redirect_to admin_administrators_path
    end
  end

  describe 'GET /admin/administrators/:id/edit' do
    let(:another_admin) { create(:admin) }

    it 'responds 200' do
      get edit_admin_administrator_path(another_admin)

      expect(response).to have_http_status :ok
    end
  end

  describe 'PATCH /admin/administrators/:id' do
    let(:another_admin) { create(:admin, scopes: []) }

    context 'with valid params' do
      let(:params) do
        {
          administrator: {
            scope: %w[write:lives],
          },
        }
      end

      it 'updates scope and redirects to /admin/administrators' do
        patch admin_administrator_path(another_admin), params: params

        expect(another_admin.reload.scopes).to contain_exactly 'write:lives'
        expect(response).to redirect_to admin_administrators_path
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          administrator: {
            scope: 'invalid',
          },
        }
      end

      it 'responds 422' do
        patch admin_administrator_path(another_admin), params: params

        expect(another_admin.reload.scopes).to be_empty
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'DELETE /admin/members/:member_id/admin' do
    let(:another_admin) { create(:admin) }

    before do
      allow(AdminActivityNotifyJob).to receive(:perform_now)
    end

    it 'destroys the user and redirects to /admin/administrators' do
      delete admin_administrator_path(another_admin)

      expect { another_admin.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(response).to redirect_to admin_administrators_path
    end
  end
end
