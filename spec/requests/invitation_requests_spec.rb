require 'rails_helper'

RSpec.describe 'Invitation requests:', type: :request do
  describe 'GET /members/:member_id/invitation/new' do
    let(:member) { create(:member) }

    before do
      log_in_as create(:user)
    end

    context 'when there is no user associated with the member' do
      it 'responds 200' do
        get new_member_invitation_path(member)

        expect(response).to have_http_status :ok
      end
    end

    context 'when a user associated with the member exists' do
      before do
        create(:user, member: member)
      end

      it 'redirects to /members/:id with alert' do
        get new_member_invitation_path(member)

        expect(response).to redirect_to member
        expect(flash.alert).to eq 'すでに招待が完了しています'
      end
    end
  end

  describe 'POST /members/:member_id/invitation' do
    let(:member) { create(:member) }

    before do
      log_in_as create(:user)
    end

    context 'with valid email' do
      let(:params) do
        {
          invitation: {
            email: 'valid@example.com',
          },
        }
      end

      it 'redirects to /members/:id with notice, and sends email' do
        expect do
          post member_invitation_path(member), params: params
        end.to change { ActionMailer::Base.deliveries.size }.by(1)

        expect(response).to redirect_to member
        expect(flash.notice).to eq '招待メールを送信しました'
      end
    end

    context 'with invalid email' do
      let(:params) do
        {
          invitation: {
            email: 'invalid',
          },
        }
      end

      it 'redirects to /members/:id with notice' do
        post member_invitation_path(member), params: params

        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'when a user associated with the member exists' do
      let(:params) do
        {
          invitation: {
            email: 'valid@example.com',
          },
        }
      end

      before do
        create(:user, member: member)
      end

      it 'redirects to /members/:id' do
        post member_invitation_path(member), params: params

        expect(response).to redirect_to member
        expect(flash.alert).to eq 'すでに招待が完了しています'
      end
    end
  end
end
