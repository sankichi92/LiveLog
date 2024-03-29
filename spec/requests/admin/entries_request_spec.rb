# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/songs request:' do
  let(:admin) { create(:admin, scopes: %w[read:entries write:entries]) }

  before do
    log_in_as admin.user
  end

  describe 'GET /admin/entries' do
    before do
      create_list(:entry, 3)
    end

    context 'without playable_time' do
      it 'responds 200' do
        get admin_entries_path

        expect(response).to have_http_status :ok
      end
    end

    context 'with playable_time' do
      it 'responds 200' do
        get admin_entries_path(playable_time: Time.zone.now.iso8601)

        expect(response).to have_http_status :ok
      end
    end
  end

  describe 'GET /admin/entries/:id/edit' do
    let(:entry) { create(:entry) }

    it 'responds 200' do
      get edit_admin_entry_path(entry)

      expect(response).to have_http_status :ok
    end
  end

  describe 'PATCH /admin/entries/:id' do
    let(:entry) { create(:entry) }
    let(:params) do
      {
        entry: {
          notes: entry.notes,
          admin_memo:,
          playable_times_attributes: entry.playable_times.map.with_index do |playable_time, i|
            [
              i.to_s,
              {
                id: playable_time.id.to_s,
                lower: playable_time.lower.iso8601,
                upper: playable_time.upper.iso8601,
                _destroy: '0',
              },
            ]
          end.to_h,
        },
        song: {
          live_id: entry.song.live_id,
          position: song_position,
        },
      }
    end

    context 'with valid params' do
      let(:admin_memo) { '確定' }
      let(:song_position) { entry.song.position + 1 }

      it 'updates the entry and redirects to /admin/entries' do
        patch(admin_entry_path(entry), params:)

        expect(entry.reload.admin_memo).to eq admin_memo
        expect(entry.song.position).to eq song_position
        expect(response).to redirect_to admin_entries_path
      end
    end

    context 'with invalid params' do
      let(:admin_memo) { '確定' }
      let(:song_position) { nil }

      it 'responds 422' do
        patch(admin_entry_path(entry), params:)

        expect(entry.reload.admin_memo).not_to eq admin_memo
        expect(entry.song.position).not_to eq song_position
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'DELETE /admin/entries/:id' do
    let(:entry) { create(:entry) }

    before do
      allow(AdminActivityNotifyJob).to receive(:perform_now)
    end

    it 'destroys the entry and redirects to /admin/entries' do
      delete admin_entry_path(entry)

      expect(response).to redirect_to admin_entries_path
      expect { entry.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
