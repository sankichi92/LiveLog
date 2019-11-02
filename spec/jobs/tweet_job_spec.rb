require 'rails_helper'

RSpec.describe TweetJob, type: :job do
  describe '#perform_now' do
    let(:twitter_client) { instance_spy(Twitter::REST::Client) }

    before do
      allow(Twitter::REST::Client).to receive(:new) { twitter_client }
    end

    it 'tweets' do
      TweetJob.perform_now('tweet')
      expect(twitter_client).to have_received(:update)
    end
  end
end
