require 'rails_helper'

RSpec.describe 'Api::V1::Pickups', type: :request do
  let!(:song) { create(:song) }
  let(:headers) { authorized_headers(create(:token)) }

  describe 'GET /api/v1/pickups/:id' do
    let(:expected_body) do
      {
        id: Integer,
        name: String,
        artist: String,
        order: Integer,
        time: Object,
        youtube_id: String,
        comment: String,
        live: Hash,
        playings: Array
      }
    end

    before do
      allow(Rails.cache).to receive(:fetch).and_return(song)
    end

    it 'responds with valid status and json' do
      get api_v1_pickup_path(Time.zone.today.strftime('%Y-%m-%d')), headers: headers
      expect(response).to have_http_status(200)
      expect(response.body).to be_json_as(expected_body)
    end
  end
end
