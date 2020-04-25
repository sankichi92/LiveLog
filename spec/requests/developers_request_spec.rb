require 'rails_helper'

RSpec.describe 'developers request:', type: :request do
  describe 'GET /settings/developer' do
    let(:user) { create(:user) }

    before do
      log_in_as user
    end

    context 'without developer' do
      it 'responds 200' do
        get developer_path

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with developer' do
      before do
        developer = create(:developer, user: user)
        create_pair(:client, developer: developer)
      end

      it 'responds 200' do
        get developer_path

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
