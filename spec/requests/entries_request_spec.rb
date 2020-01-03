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
end
