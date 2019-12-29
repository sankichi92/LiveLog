require 'twitter_client'

class TweetJob < ApplicationJob
  queue_as :default

  def perform(tweet)
    TwitterClient.update(tweet)
  end
end
