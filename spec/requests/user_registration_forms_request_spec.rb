# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'user_registration_forms request:', type: :request do
  describe 'GET /register/:token' do
    let(:token) { user_registration_form.token }

    context 'with an active token' do
      let(:user_registration_form) { create(:user_registration_form) }

      it 'responds 200' do
        get user_registration_form_path(token)

        expect(response).to have_http_status :ok
      end
    end

    context 'with an expired token' do
      let(:user_registration_form) { create(:user_registration_form, :expired) }

      it 'redirects to /' do
        get user_registration_form_path(token)

        expect(response).to redirect_to root_path
      end
    end
  end
end
