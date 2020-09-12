# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Developer, type: :model do
  describe '#fetch_github_user!' do
    let(:developer) { create(:developer, github_username: 'sankichi92') }

    let(:octokit_client) { instance_double(Octokit::Client, user: response) }
    let(:response) { { login: developer.github_username } }

    before do
      allow(Octokit::Client).to receive(:new).with(access_token: developer.github_access_token).and_return(octokit_client)
    end

    it 'calls Octokit::Client#user' do
      github_user = developer.fetch_github_user!

      expect(octokit_client).to have_received(:user)
      expect(github_user).to eq response
    end

    context 'when returned github_username if different from current github_username' do
      let(:response) { { login: "#{developer.github_username}_new" } }

      it 'calls Octokit::Client#user and update github_username' do
        github_user = developer.fetch_github_user!

        expect(octokit_client).to have_received(:user)
        expect(github_user).to eq response
        expect(developer.reload.github_username).to eq response[:login]
      end
    end

    context 'when github_access_token has been revoked' do
      before do
        allow(octokit_client).to receive(:user).and_raise(Octokit::Unauthorized)
      end

      it 'destroys the receiver and raises Octokit::Unauthorized' do
        expect { developer.fetch_github_user! }.to raise_error(Octokit::Unauthorized)

        expect { developer.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context 'with clients' do
        before do
          create_pair(:client, developer: developer)
        end

        it 'removes github_access_token and raises Octokit::Unauthorized' do
          expect { developer.fetch_github_user! }.to raise_error(Octokit::Unauthorized)

          expect(developer.reload.github_access_token).to be_nil
        end
      end
    end
  end
end
