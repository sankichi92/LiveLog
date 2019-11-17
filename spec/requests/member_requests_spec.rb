require 'rails_helper'

RSpec.describe 'Member requests', type: :request do
  describe 'GET /members' do
    before do
      create_pair(:member)
    end

    it 'responds 200' do
      get members_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /members/year/:year' do
    context 'when members exist' do
      let(:year) { Time.zone.now.year }

      before do
        create_pair(:member, joined_year: year)
      end

      it 'responds 200' do
        get year_members_path(year: year)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when members do not exist' do
      let(:year) { Time.zone.now.year }

      before do
        create_pair(:member, joined_year: year - 1)
      end

      it 'responds 404' do
        expect { get year_members_path(year: year) }.to raise_error ActionController::RoutingError
      end
    end
  end

  describe 'GET /members/:id' do
    let(:member) { create(:member) }

    before do
      2.times do
        create(:song, members: [member, create(:member)])
      end
    end

    it 'responds 200' do
      get member_path(member)

      expect(response).to have_http_status(:ok)
    end
  end
end
