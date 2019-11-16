require 'rails_helper'

RSpec.describe 'Entry requests', type: :request do
  let(:user) { create(:user) }

  before { log_in_as user, capybara: false }

  describe 'GET /lives/:live_id/entries' do
    context 'when live is published' do
      let(:live) { create(:live) }

      it 'redirects to /lives/:id' do
        get live_entries_path(live)

        expect(response).to redirect_to(live)
      end
    end

    context 'when live is unpublished' do
      let(:live) { create(:live, :draft) }

      before do
        create_pair(:song, :draft, live: live, members: create_pair(:member))
      end

      it 'responds 200' do
        get live_entries_path(live)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /lives/:live_id/entries/new' do
    context 'when live is published' do
      let(:live) { create(:live) }

      it 'redirects to /lives/:id' do
        get new_live_entry_path(live)
        expect(response).to redirect_to(live)
      end
    end

    context 'when live is unpublished' do
      let(:live) { create(:live, :draft) }

      it 'responds 200' do
        get new_live_entry_path(live)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /lives/:live_id/entries with xhr' do
    context 'when live is published' do
      let(:live) { create(:live) }

      it 'redirects to /lives/:id' do
        post live_entries_path(live), xhr: true
        expect(response).to redirect_to(live)
      end
    end

    context 'when live is unpublished' do
      let(:live) { create(:live, :draft) }
      let(:entry_attrs) { { preferred_rehearsal_time: '', preferred_performance_time: '', notes: '' } }

      before { ActionMailer::Base.deliveries.clear }

      context 'with valid params' do
        let(:song_attrs) { attributes_for(:song, :draft) }

        it 'creates a song, send an email and redirects /lives/:id/entries' do
          expect {
            post live_entries_path(live), params: { song: song_attrs, entry: entry_attrs }, xhr: true
          }.to change(Song, :count).by(1)
          expect(ActionMailer::Base.deliveries.size).to eq 1
          expect(response).to redirect_to(live_entries_url(live))
        end
      end

      context 'with invalid params' do
        let(:song_attrs) { attributes_for(:song, :draft, :invalid) }

        it 'responds 422' do
          expect {
            post live_entries_path(live), params: { song: song_attrs, entry: entry_attrs }, xhr: true
          }.not_to change(Song, :count)
          expect(ActionMailer::Base.deliveries.size).to eq 0
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
