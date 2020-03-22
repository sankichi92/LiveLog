require 'rails_helper'

RSpec.describe 'entry_guidelines request:', type: :request do
  describe 'GET /lives/:live_id/entry_guideline' do
    let(:entry_guideline) { create(:entry_guideline) }

    it 'responds 200 with JSON' do
      get live_entry_guideline_path(entry_guideline.live)

      expect(response).to have_http_status :ok
      expect(JSON.parse(response.body)).to include 'deadline', 'notes'
    end
  end
end
