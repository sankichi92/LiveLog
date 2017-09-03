require 'rails_helper'

RSpec.describe 'Api::V1::RegularMeetings', type: :request do

  describe 'GET /api/v1/regular_meetings/:id' do
    let(:date) { Time.zone.today }
    let(:place) { '4共21' }
    let(:note) { '20時まで音出し不可' }
    let(:place_url) { 'http://s.maho.jp/homepage/7cffb2d25ef87ff8/1' }
    let(:expected_body) do
      {
        date: date.to_s,
        place: place,
        note: note,
        place_url: place_url
      }
    end

    before do
      regular_meeting = instance_double('RegularMeeting', date: date, place: place, note: note, place_url: place_url)
      allow(Rails.cache).to receive(:fetch).and_return(regular_meeting)
    end

    it 'responds with valid status and json' do
      get api_v1_regular_meeting_path(date.strftime('%Y-%m-%d'))
      expect(response).to have_http_status(200)
      expect(response.body).to be_json_as(expected_body)
    end
  end
end
