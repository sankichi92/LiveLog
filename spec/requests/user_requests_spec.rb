require 'rails_helper'

RSpec.describe 'User requests', type: :request do
  describe 'GET /members' do
    it 'responds 200' do
      get users_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /members/:id by logged-in user' do
    let(:user) { create(:user) }

    before { log_in_as(create(:user), capybara: false) }

    it 'responds 200' do
      get user_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /members/new by admin' do
    before { log_in_as(create(:admin), capybara: false) }

    it 'responds 200' do
      get new_user_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /members by admin' do
    before { log_in_as(create(:admin), capybara: false) }

    context 'with valid params' do
      let(:user_attrs) { attributes_for(:user) }

      it 'creates a user and redirects to /users/new' do
        expect { post users_path, params: { user: user_attrs } }.to change(User, :count).by(1)
        expect(response).to redirect_to(new_user_url)
      end
    end

    context 'with invalid params' do
      let(:user_attrs) { attributes_for(:user, :invalid) }

      it 'responds 422' do
        expect { post users_path, params: { user: user_attrs } }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /members/:id/edit by correct user' do
    let(:user) { create(:user) }

    before { log_in_as(user, capybara: false) }

    it 'responds 200' do
      get edit_user_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /members/:id by correct user' do
    let(:user) { create(:user) }

    before { log_in_as(user, capybara: false) }

    context 'with valid params' do
      let(:new_user_attrs) { attributes_for(:user, nickname: 'new nickname') }

      it 'updates the user and redirects to /members/:id' do
        patch user_path(user), params: { user: new_user_attrs }
        expect(response).to redirect_to(user_url(user))
        expect(user.reload.nickname).to eq 'new nickname'
      end
    end

    context 'with invalid params' do
      let(:new_user_attrs) { attributes_for(:user, last_name: '') }

      it 'responds 422' do
        patch user_path(user), params: { user: new_user_attrs }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.reload.last_name).not_to eq ''
      end
    end
  end

  describe 'DELETE /members/:id by admin' do
    let!(:user) { create(:user) }

    before { log_in_as(create(:admin), capybara: false) }

    context 'when the user has no songs' do
      it 'deletes the user and redirects to /members' do
        expect { delete user_path(user) }.to change(User, :count).by(-1)
        expect(response).to redirect_to(users_url)
      end
    end

    context 'when the user has one or more songs' do
      before { create(:song, users: [user]) }

      it 'responds 422' do
        expect { delete user_path(user) }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /members/:id/password/edit by correct user' do
    let(:user) { create(:user) }

    before { log_in_as(user, capybara: false) }

    it 'responds 200' do
      get edit_user_password_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /members/:id/password by correct user' do
    let(:user) { create(:user) }

    before { log_in_as(user, capybara: false) }

    context 'with valid params' do
      let(:new_password_attrs) { { password: 'new_password' } }

      it 'updates the user and redirects to /members/:id' do
        patch user_password_path(user), params: { current_password: user.password, user: new_password_attrs }
        expect(response).to redirect_to(user_url(user))
        expect(user.password_digest).not_to eq user.reload.password_digest
      end
    end

    context 'with invalid params' do
      let(:new_password_attrs) { { password: '1234' } }

      it 'responds 422' do
        patch user_password_path(user), params: { current_password: user.password, user: new_password_attrs }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.password_digest).to eq user.reload.password_digest
      end
    end
  end
end
