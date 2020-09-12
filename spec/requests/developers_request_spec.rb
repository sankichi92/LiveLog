# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'developers request:', type: :request do
  describe 'GET /settings/developer' do
    let(:user) { create(:user) }

    before do
      log_in_as user
    end

    it 'responds 200' do
      get developer_path

      expect(response).to have_http_status(:ok)
    end

    context 'with developer' do
      before do
        developer = create(:developer, user: user)
        create_list(:client, Faker::Number.within(range: 0..2), developer: developer)

        allow(Octokit::Client).to receive(:new).with(access_token: developer.github_access_token).and_return(
          instance_double(Octokit::Client, user: {}),
        )
      end

      it 'responds 200' do
        get developer_path

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with developer but their github_access_token has been revoked' do
      before do
        developer = create(:developer, user: user)
        create_list(:client, Faker::Number.within(range: 0..2), developer: developer)

        allow(Octokit::Client).to receive(:new).with(access_token: developer.github_access_token).and_return(
          instance_double(Octokit::Client).tap { |client| allow(client).to receive(:user).and_raise(Octokit::Unauthorized) },
        )
      end

      it 'responds 200' do
        get developer_path

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
