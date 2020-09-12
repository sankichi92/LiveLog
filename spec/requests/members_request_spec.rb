require 'rails_helper'

RSpec.describe 'members request:', type: :request do
  describe 'GET /members' do
    before do
      create_pair(:member)
    end

    it 'responds 200' do
      get members_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /members/year/:year' do
    context 'when members exist' do
      let(:year) { Time.zone.now.year }

      before do
        create_pair(:member, joined_year: year)
      end

      it 'responds 200' do
        get year_members_path(year: year)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when members do not exist' do
      let(:year) { Time.zone.now.year }

      before do
        create_pair(:member, joined_year: year - 1)
      end

      it 'responds 404' do
        expect { get year_members_path(year: year) }.to raise_error ActionController::RoutingError
      end
    end
  end

  describe 'GET /members/:id' do
    let(:member) { create(:member) }

    before do
      create_list(:song, 2, members: [member, create(:member)])
    end

    it 'responds 200' do
      get member_path(member)

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /register/:user_registration_form_token/members' do
    let!(:token) { user_registration_form.token }
    let(:user_registration_form) { create(:user_registration_form) }
    let(:params) do
      {
        member: {
          joined_year: joined_year,
          name: 'ベス',
        },
        user: {
          email: email,
        },
      }
    end
    let(:joined_year) { Time.zone.now.year.to_s }
    let(:email) { 'bass@example.com' }

    let(:auth0_client) do
      double(:app_auth0_client).tap do |auth0_client|
        allow(auth0_client).to receive(:user).and_raise(Auth0::NotFound.new('The user does not exist.'))
        allow(auth0_client).to receive(:create_user).and_return('user_id' => 'auth0|0', 'email' => email)
        allow(auth0_client).to receive(:change_password)
      end
    end

    before do
      allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)
    end

    context 'with valid member and user params' do
      it 'create a member and a user, requests Auth0 to create a user, and redirects to /' do
        expect { post user_registration_form_members_path(token), params: params }
          .to change(Member, :count).by(1).and change(User, :count).by(1).and change { user_registration_form.reload.used_count }.by(1)

        expect(auth0_client).to have_received(:create_user)
        expect(auth0_client).to have_received(:change_password).with(email, nil)
        expect(response).to have_http_status :redirect
      end
    end

    context 'with invalid user params' do
      let(:email) { 'invalid' }

      it 'responds 422' do
        expect { post user_registration_form_members_path(token), params: params }
          .to change(Member, :count).by(0).and change(User, :count).by(0)

        expect(auth0_client).not_to have_received(:create_user)
        expect(auth0_client).not_to have_received(:change_password)
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'with invalid member params' do
      let(:joined_year) { '' }

      it 'responds 422' do
        expect { post user_registration_form_members_path(token), params: params }
          .to change(Member, :count).by(0).and change(User, :count).by(0)

        expect(auth0_client).not_to have_received(:create_user)
        expect(auth0_client).not_to have_received(:change_password)
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'with an expired token' do
      let(:user_registration_form) { create(:user_registration_form, :expired) }

      it 'redirects to /' do
        expect { post user_registration_form_members_path(token), params: params }
          .to change(Member, :count).by(0).and change(User, :count).by(0)

        expect(auth0_client).not_to have_received(:create_user)
        expect(auth0_client).not_to have_received(:change_password)
        expect(response).to redirect_to root_path
        expect(flash.alert).to include '有効期限が切れています'
      end
    end
  end
end
