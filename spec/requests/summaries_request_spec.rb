require 'rails_helper'

RSpec.describe 'summaries request:', type: :request do
  describe 'GET /summaries' do
    let(:latest_live_date) { Time.zone.today }

    before do
      create(:live, date: latest_live_date)
      create(:live, date: 1.year.ago)
    end

    it 'redirects to the latest summary page' do
      get summaries_path

      expect(response).to redirect_to summary_path(latest_live_date.nendo)
    end
  end

  describe 'GET /summaries/:year' do
    let(:live_date) { Time.zone.today }

    before do
      live = create(:live, date: live_date)
      3.times do
        members = create_list(:member, 3)
        create(:song, live: live, members: members)
      end
    end

    it 'responds 200' do
      get summary_path(live_date.nendo)

      expect(response).to have_http_status :ok
    end

    context 'with invalid year' do
      it 'raises ActionController::RoutingError' do
        expect { get summary_path(live_date.nendo - 1) }.to raise_error ActionController::RoutingError
      end
    end
  end
end
