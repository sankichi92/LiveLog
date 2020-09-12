# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/lives request:', type: :request do
  let(:admin) { create(:admin, scopes: %w[write:lives]) }

  before do
    log_in_as admin.user
  end

  describe 'GET /admin/lives' do
    before do
      create_pair(:live)
      create_pair(:live, :unpublished)
    end

    it 'responds 200' do
      get admin_lives_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'GET /admin/lives/new' do
    it 'responds 200' do
      get new_admin_live_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'POST /admin/lives' do
    context 'with valid params' do
      let(:params) do
        {
          live: {
            date: date.to_s,
            name: '6月ライブ',
            place: '4共21',
            comment: '',
            album_url: '',
          },
        }
      end
      let(:date) { Time.zone.today }

      it 'creates a live and redirects to /admin/lives' do
        expect { post admin_lives_path, params: params }.to change(Live, :count).by(1)

        expect(response).to redirect_to admin_lives_path(year: date.nendo)
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          live: {
            date: '',
            name: '',
            place: '',
            comment: '',
            album_url: '',
          },
        }
      end

      it 'responds 422' do
        expect { post admin_lives_path, params: params }.not_to change(Live, :count)

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'GET /admin/lives/:id/edit' do
    let(:live) { create(:live) }

    it 'responds 200' do
      get edit_admin_live_path(live)

      expect(response).to have_http_status :ok
    end
  end

  describe 'PATCH /admin/lives/:id' do
    let(:live) { create(:live, album_url: '') }
    let(:params) do
      {
        live: {
          date: live.date.to_s,
          name: name,
          place: live.place,
          comment: comment,
          album_url: album_url,
        },
      }
    end
    let(:name) { live.name }
    let(:comment) { live.comment }
    let(:album_url) { live.album_url }

    context 'with valid params' do
      let(:comment) { '楽しいライブでした' }
      let(:album_url) { 'https://goo.gl/photos/album' }

      it 'updates the live and redirects to /admin/lives' do
        patch admin_live_path(live), params: params

        expect(live.reload.album_url).to eq album_url
        expect(live.comment).to eq comment
        expect(response).to redirect_to admin_lives_path(year: live.date.nendo)
      end
    end

    context 'with invalid params' do
      let(:name) { 'a' * 21 }

      it 'responds 422' do
        patch admin_live_path(live), params: params

        expect(live.reload.name).not_to eq name
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'DELETE /admin/lives/:id' do
    let(:live) { create(:live) }

    before do
      allow(AdminActivityNotifyJob).to receive(:perform_now)
    end

    it 'destroys the live and redirects to /admin/lives' do
      delete admin_live_path(live)

      expect(response).to redirect_to admin_lives_path(year: live.date.nendo)
      expect { live.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe 'POST /admin/lives/:id/publish', elasticsearch: true do
    let(:live) { create(:live, :unpublished) }

    it 'publishes the live and redirects to /admin/lives' do
      expect { post publish_admin_live_path(live) }.to change { ActionMailer::Base.deliveries.size }.by(1)

      expect(live.reload).to be_published
      expect(response).to redirect_to admin_lives_path(year: live.date.nendo)
    end
  end
end
