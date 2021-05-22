# frozen_string_literal: true

require 'livelog/twitter_client'

class TweetJob < ApplicationJob
  queue_as :default

  def perform(tweet)
    TwitterClient.instance.update(tweet)
  end
end
