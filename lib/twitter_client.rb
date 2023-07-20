# frozen_string_literal: true

require 'net/http'
require 'uri'

require 'simple_oauth'

class TwitterClient
  def initialize(consumer_key:, consumer_secret:, token:, token_secret:)
    @oauth_options = {
      consumer_key:,
      consumer_secret:,
      token:,
      token_secret:,
    }
  end

  def tweet(text)
    uri = URI('https://api.twitter.com/2/tweets')
    data = { text: }.to_json
    headers = {
      'Authorization' => SimpleOAuth::Header.new(:post, uri, {}, @oauth_options).to_s,
      'Content-Type' => 'application/json',
    }
    response = Net::HTTP.post(uri, data, headers)
    response.value
    response
  end
end
