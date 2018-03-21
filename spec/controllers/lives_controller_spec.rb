require 'rails_helper'

RSpec.describe LivesController, type: :controller do
  subject { response }

  describe 'GET index' do
    before { get :index }
    it { is_expected.to have_http_status(:ok) }
  end

  describe 'GET show' do
    let(:live) { create(:live) }
    before { get :show, params: { id: live.id } }

    context 'published live' do
      it { is_expected.to have_http_status(:ok) }
    end

    context 'unpublished live' do
      let(:live) { create(:draft_live) }
      it { is_expected.to redirect_to(live_entries_url(live)) }
    end
  end

  describe 'GET new' do
    before { get :new, session: { user_id: user&.id } }

    context 'by a non-admin user' do
      let(:user) { create(:user) }
      it { is_expected.to redirect_to(root_url) }
    end

    context 'by an admin user' do
      let(:user) { create(:admin) }
      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'GET edit' do
    let(:live) { create(:live) }
    before { get :edit, params: { id: live.id }, session: { user_id: user&.id } }

    context 'by a non-admin user' do
      let(:user) { create(:user) }
      it { is_expected.to redirect_to(root_url) }
    end

    context 'by an admin user' do
      let(:user) { create(:admin) }
      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'POST create' do
    let(:live_attrs) { attributes_for(:live) }
    before { post :create, params: { live: live_attrs }, session: { user_id: user&.id } }

    context 'by a non-admin user' do
      let(:user) { create(:user) }
      it { is_expected.to redirect_to(root_url) }
    end

    context 'by an admin user' do
      let(:user) { create(:admin) }

      context 'with valid params' do
        it { is_expected.to redirect_to(Live.last) }
      end

      context 'with invalid params' do
        let(:live_attrs) { { name: '' } }
        it { is_expected.to have_http_status(:unprocessable_entity) }
      end
    end
  end

  describe 'PATCH update' do
    let(:live) { create(:live) }
    let(:new_live_attrs) { attributes_for(:live, place: 'updated place') }

    before do
      patch :update, params: { id: live.id, live: new_live_attrs }, session: { user_id: user&.id }
    end

    context 'by a non-admin user' do
      let(:user) { create(:user) }
      it { is_expected.to redirect_to(root_url) }
    end

    context 'by an admin user' do
      let(:user) { create(:admin) }

      context 'with valid params' do
        it { is_expected.to redirect_to(live) }
        it { expect(live.reload.place).to eq 'updated place' }
      end

      context 'with invalid params' do
        let(:new_live_attrs) { { name: '' } }
        it { is_expected.to have_http_status(:unprocessable_entity) }
      end
    end
  end

  describe 'DELETE destroy' do
    let(:live) { create(:live) }
    before { delete :destroy, params: { id: live.id }, session: { user_id: user&.id } }

    context 'by a non-admin user' do
      let(:user) { create(:user) }
      it { is_expected.to redirect_to(root_url) }
    end

    context 'by an admin user' do
      let(:user) { create(:admin) }

      context 'when the live has one or more songs' do
        let(:live) { create(:live, :with_songs) }
        it { is_expected.to have_http_status(:unprocessable_entity) }
      end

      context 'when the live has no songs' do
        it { is_expected.to redirect_to(lives_url) }
        it { expect { live.reload }.to raise_error ActiveRecord::RecordNotFound }
      end
    end
  end
end
