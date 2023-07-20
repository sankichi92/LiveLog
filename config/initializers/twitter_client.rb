# frozen_string_literal: true

require 'twitter_client'

Rails.configuration.x.twitter_client = TwitterClient.new(
  consumer_key: ENV['TWITTER_CONSUMER_KEY'],
  consumer_secret: ENV['TWITTER_CONSUMER_SECRET'],
  token: ENV['TWITTER_ACCESS_TOKEN'],
  token_secret: ENV['TWITTER_ACCESS_TOKEN_SECRET'],
)
