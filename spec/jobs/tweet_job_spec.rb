require 'rails_helper'

RSpec.describe TweetJob, type: :job do
  describe '#perform_now' do
    let(:twitter_client) { double('twitter_client') }

    before do
      allow(Twitter::REST::Client).to receive(:new) { twitter_client }
    end

    it 'tweets' do
      expect(twitter_client).to receive(:update)
      described_class.perform_now('tweet')
    end
  end
end
