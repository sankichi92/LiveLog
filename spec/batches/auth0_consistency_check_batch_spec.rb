# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth0ConsistencyCheckBatch, type: :batch do
  describe '#run' do
    subject(:run) { described_class.new(sleep_duration: 0).run }

    let(:users) { create_list(:user, 5) }

    let(:response_total) { 5 }
    let(:second_response) do
      {
        'start' => 3,
        'length' => 2,
        'total' => response_total,
        'users' => users[3..4].map { |user| { 'user_id' => user.auth0_id } },
      }
    end

    before do
      auth0_client = double(:auth0_client).tap do |double|
        allow(double).to receive(:users).with(hash_including(page: 0)).and_return(
          'start' => 0,
          'length' => 3,
          'total' => response_total,
          'users' => users[0..2].map { |user| { 'user_id' => user.auth0_id } },
        )

        allow(double).to receive(:users).with(hash_including(page: 1)).and_return(second_response)
      end

      allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)
    end

    context 'when there is no consistency' do
      it 'returns empty results' do
        results = run

        expected_results = {
          only_auth0_ids: [],
          only_livelog_ids: [],
        }

        expect(results).to eq expected_results
      end
    end

    context 'when there is no Auth0 user corresponding to a LiveLog user' do
      let(:response_total) { 4 }
      let(:second_response) do
        {
          'start' => 3,
          'length' => 1,
          'total' => response_total,
          'users' => users[3..3].map { |user| { 'user_id' => user.auth0_id } },
        }
      end

      it 'raises an error with a message including inconsistent LiveLog user id' do
        expected_results = {
          only_auth0_ids: [],
          only_livelog_ids: [users[4].auth0_id],
        }

        expect { run }.to raise_error(Auth0ConsistencyCheckBatch::Error, expected_results.inspect)
      end
    end

    context 'when there is no LiveLog user corresponding to a Auth0 user' do
      let(:response_total) { 6 }
      let(:second_response) do
        {
          'start' => 3,
          'length' => 3,
          'total' => response_total,
          'users' => users[3..4].map { |user| { 'user_id' => user.auth0_id } } + [{ 'user_id' => 'auth0|0' }],
        }
      end

      it 'raises an error with a message including inconsistent LiveLog user id' do
        expected_results = {
          only_auth0_ids: ['auth0|0'],
          only_livelog_ids: [],
        }

        expect { run }.to raise_error(Auth0ConsistencyCheckBatch::Error, expected_results.inspect)
      end
    end
  end
end
