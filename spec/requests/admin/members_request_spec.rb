require 'rails_helper'

RSpec.describe 'admin/members request:', type: :request do
  let(:admin) { create(:admin) }

  before do
    log_in_as admin
  end

  describe 'GET /admin/members' do
    before do
      create_pair(:member)
      create_pair(:member, :with_user)
    end

    it 'responds 200' do
      get admin_members_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'GET /admin/members/new' do
    it 'responds 200' do
      get new_admin_member_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'POST /admin/members' do
    let(:params) do
      {
        member: {
          joined_year: joined_year,
          name: 'ギータ',
        },
        user: {
          email: email,
        },
      }
    end

    context 'with valid member and user params' do
      let(:joined_year) { Time.zone.now.year.to_s }
      let(:email) { 'guitar@example.com' }

      let(:auth0_client) { spy(:app_auth0_client) }

      before do
        allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)
      end

      it 'creates a member and a user, requests Auth0 to create user, and redirects to /admin/members' do
        expect { post admin_members_path, params: params }.to change(Member, :count).by(1).and change(User, :count).by(1)

        expect(auth0_client).to have_received(:create_user).with(anything, hash_including(email: email)).once
        expect(auth0_client).to have_received(:change_password).with(email, nil).once
        expect(response).to redirect_to admin_members_path(year: joined_year)
        expect(flash.notice).to include '追加しました'
      end

      context 'when Auth0 responds 400' do
        before do
          allow(auth0_client).to receive(:create_user).and_raise(Auth0::BadRequest, '400')
        end

        it 'creates a member and redirects to /admin/members with alert' do
          expect { post admin_members_path, params: params }.to change(Member, :count).by(1).and change(User, :count).by(0)

          expect(response).to redirect_to admin_members_path(year: joined_year)
          expect(flash.alert).to include '招待メールの送信に失敗しました'
        end
      end
    end

    context 'with valid member params and invalid user params' do
      let(:joined_year) { Time.zone.now.year.to_s }
      let(:email) { '' }

      it 'creates a member and redirects to /admin/members' do
        expect { post admin_members_path, params: params }.to change(Member, :count).by(1).and change(User, :count).by(0)

        expect(response).to redirect_to admin_members_path(year: joined_year)
        expect(flash.notice).to include '追加しました'
      end
    end

    context 'with invalid member params' do
      let(:joined_year) { '' }
      let(:email) { '' }

      it 'responds 422' do
        expect { post admin_members_path, params: params }.not_to change(Member, :count)

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'DELETE /admin/members/:id' do
    let(:member) { create(:member) }

    it 'destroys the member and redirects to /admin/members' do
      delete admin_member_path(member)

      expect(response).to redirect_to admin_members_path(year: member.joined_year)
      expect { member.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
