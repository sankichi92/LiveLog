require 'rails_helper'

RSpec.describe 'admin/user_registration_forms request:', type: :request do
  let(:admin) { create(:admin) }

  before do
    log_in_as admin
  end

  describe 'GET /admin/user_registration_forms' do
    before do
      create_pair(:user_registration_form)
    end

    it 'responds 200' do
      get admin_user_registration_forms_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'GET /admin/user_registration_forms/new' do
    it 'responds 200' do
      get new_admin_user_registration_form_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'POST /admin/user_registration_forms' do
    context 'with valid params' do
      let(:params) do
        {
          user_registration_form: {
            active_days: 30,
          },
        }
      end

      it 'creates a user_registration_form and redirects to /admin/user_registration_forms' do
        expect { post admin_user_registration_forms_path, params: params }.to change(UserRegistrationForm, :count).by(1)

        expect(response).to redirect_to admin_user_registration_forms_path
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          user_registration_form: {
            active_days: 31,
          },
        }
      end

      it 'responds 422' do
        expect { post admin_user_registration_forms_path, params: params }.not_to change(UserRegistrationForm, :count)

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'DELETE /admin/user_registration_forms/:id' do
    let(:user_registration_form) { create(:user_registration_form) }

    before do
      allow(AdminActivityNotifyJob).to receive(:perform_now)
    end

    it 'destroys the user_registration_form and redirects to /admin/user_registration_forms' do
      delete admin_user_registration_form_path(user_registration_form)

      expect(response).to redirect_to admin_user_registration_forms_path
      expect { user_registration_form.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
