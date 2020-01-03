require 'rails_helper'

RSpec.describe 'entries request:', type: :request do
  describe 'GET /entries' do
    let(:user) { create(:user) }

    before do
      3.times do
        song = create(:song, members: [user.member])
        create(:entry, song: song)
      end

      log_in_as user
    end

    it 'responds 200' do
      get entries_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'GET /entries/new' do
    before do
      log_in_as create(:user)
    end

    context 'when an unpublished live exists' do
      before do
        create(:live, :unpublished)
      end

      it 'responds 200' do
        get new_entry_path

        expect(response).to have_http_status :ok
      end
    end

    context 'when any unpublished lives does not exist' do
      it 'redirects to /entries' do
        get new_entry_path

        expect(response).to redirect_to entries_path
      end
    end
  end

  describe 'POST /entries' do
    let(:user) { create(:user) }
    let(:live) { create(:live, :unpublished) }
    let(:params) do
      {
        entry: {
          notes: '',
          available_times_attributes: available_times_attributes,
        },
        song: {
          live_id: live.id.to_s,
          name: 'アンプラグドのテーマ',
          artist: '',
          original: '1',
          status: 'open',
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
      log_in_as user
    end

    context 'with valid params' do
      let(:available_times_attributes) do
        {
          '0' => {
            lower: 1.month.from_now.beginning_of_hour.iso8601,
            upper: 1.month.from_now.end_of_hour.iso8601,
            _destroy: '0',
          },
        }
      end

      it 'creates entry and redirect_to /entries' do
        expect { post entries_path, params: params }
          .to change(Entry, :count).by(1).and change(AvailableTime, :count).by(1).and change(Song, :count).by(1)

        expect(response).to redirect_to entries_path
      end
    end

    context 'with invalid params' do
      let(:available_times_attributes) { {} }

      it 'responds 422' do
        expect { post entries_path, params: params }
          .to change(Entry, :count).by(0).and change(AvailableTime, :count).by(0).and change(Song, :count).by(0)

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
