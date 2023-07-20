# frozen_string_literal: true

class TweetJob < ApplicationJob
  queue_as :default

  def perform(tweet)
    Rails.configuration.x.twitter_client.tweet(tweet)
  end
end
