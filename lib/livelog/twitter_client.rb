# frozen_string_literal: true

module LiveLog
  class TwitterClient < Twitter::REST::Client
    include Singleton

    def initialize
      @consumer_key = ENV['TWITTER_CONSUMER_KEY']
      @consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      @access_token = ENV['TWITTER_ACCESS_TOKEN']
      @access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
      super
    end
  end
end
