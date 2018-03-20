require 'rails_helper'

RSpec.describe TweetJob, type: :job do
  describe '#perform_now' do
    let(:twitter_client) { double('twitter_client') }

    before do
      allow(TwitterClient).to receive(:instance) { twitter_client }
    end

    it 'should tweet' do
      expect(twitter_client).to receive(:update)
      TweetJob.perform_now('tweet')
    end
  end
end
