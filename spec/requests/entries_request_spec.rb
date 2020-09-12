require 'rails_helper'

RSpec.describe 'entries request:', type: :request do
  include Auth0UserHelper

  describe 'GET /entries' do
    let(:user) { create(:user) }

    before do
      log_in_as user
    end

    context 'when logged-in user has entries' do
      before do
        3.times do
          song = create(:song, :for_entry, members: [user.member])
          create(:entry, song: song)
        end
      end

      it 'responds 200' do
        get entries_path

        expect(response).to have_http_status :ok
      end
    end

    context 'when logged-in user does not have entries' do
      it 'redirects to /entries/new' do
        get entries_path

        expect(response).to redirect_to new_entry_path
      end
    end
  end

  describe 'GET /entries/new' do
    before do
      log_in_as create(:user)
    end

    context 'when an unpublished live exists' do
      before do
        create(:live, :unpublished, :with_entry_guideline)
      end

      it 'responds 200' do
        get new_entry_path

        expect(response).to have_http_status :ok
      end
    end

    context 'when any unpublished lives does not exist' do
      it 'redirects with alert' do
        get new_entry_path

        expect(response).to have_http_status :redirect
        expect(flash.alert).to eq 'エントリー募集中のライブがありません'
      end
    end
  end

  describe 'POST /entries' do
    let(:user) { create(:user) }
    let(:live) { create(:live, :unpublished, :with_entry_guideline) }
    let(:params) do
      {
        entry: {
          notes: '',
          playable_times_attributes: playable_times_attributes,
        },
        song: {
          live_id: live.id.to_s,
          name: 'アンプラグドのテーマ',
          artist: '',
          original: '1',
          visibility: 'open',
          comment: '',
          plays_attributes: {
            '0' => {
              instrument: '',
              member_id: user.member.id,
              _destroy: '0',
            },
          },
        },
      }
    end

    before do
      stub_auth0_user(user)
      log_in_as user
    end

    context 'with valid params' do
      let(:playable_times_attributes) do
        {
          '0' => {
            lower: live.date.beginning_of_day.iso8601,
            upper: live.date.end_of_day.iso8601,
            _destroy: '0',
          },
        }
      end

      it 'creates entry and redirect_to /entries' do
        expect { post entries_path, params: params }
          .to change(Entry, :count).by(1).and change(PlayableTime, :count).by(1).and change(Song, :count).by(1)

        expect(response).to redirect_to entries_path
      end
    end

    context 'with invalid params' do
      let(:playable_times_attributes) { {} }

      it 'responds 422' do
        expect { post entries_path, params: params }
          .to change(Entry, :count).by(0).and change(PlayableTime, :count).by(0).and change(Song, :count).by(0)

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'GET /entries/:id/edit' do
    let(:entry) { create(:entry) }
    let(:user) { create(:user) }

    before do
      log_in_as user
    end

    context 'with submitter' do
      before do
        entry.update!(member_id: user.member_id)
      end

      it 'responds 200' do
        get edit_entry_path(entry)

        expect(response).to have_http_status :ok
      end
    end

    context 'with player' do
      before do
        create(:play, song: entry.song, member: user.member)
      end

      it 'responds 200' do
        get edit_entry_path(entry)

        expect(response).to have_http_status :ok
      end
    end

    context 'with logged-in user' do
      it 'redirects with alert' do
        get edit_entry_path(entry)

        expect(response).to have_http_status :redirect
        expect(flash.alert).to eq '権限がありません'
      end
    end
  end

  describe 'PATCH /entries/:id' do
    let(:entry) { create(:entry, notes: '', song: song, member: user.member) }
    let(:song) { create(:song, :for_entry, name: 'before') }
    let(:user) { create(:user) }
    let(:params) do
      {
        entry: {
          notes: entry_notes,
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
          live_id: entry.song.live_id.to_s,
          name: song_name,
          artist: entry.song.artist,
          original: entry.song.original? ? '1' : '0',
          visibility: entry.song.visibility,
          comment: entry.song.comment,
          plays_attributes: entry.song.plays.map.with_index do |play, i|
            [
              i.to_s,
              {
                id: play.id.to_s,
                instrument: play.instrument,
                member_id: play.member_id,
                _destroy: '0',
              },
            ]
          end.to_h,
        },
      }
    end

    before do
      log_in_as user
    end

    context 'with valid params' do
      let(:entry_notes) { 'ボーカルは座って歌います' }
      let(:song_name) { 'after' }

      it 'updates the entry and redirects to /entries' do
        patch entry_path(entry), params: params

        expect(entry.reload.notes).to eq entry_notes
        expect(entry.song.name).to eq song_name
        expect(response).to redirect_to entries_path
      end
    end

    context 'with invalid params' do
      let(:entry_notes) { 'ボーカルは座って歌います' }
      let(:song_name) { '' }

      it 'responds 422' do
        patch entry_path(entry), params: params

        expect(entry.reload.notes).not_to eq entry_notes
        expect(entry.song.name).not_to eq song_name
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'DELETE /entries/:id' do
    let(:entry) { create(:entry, member: user.member) }
    let(:user) { create(:user) }

    before do
      log_in_as user
    end

    it 'destroys the entry and redirects to /entries' do
      delete entry_path(entry)

      expect(response).to redirect_to entries_path
      expect { entry.song.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { entry.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
