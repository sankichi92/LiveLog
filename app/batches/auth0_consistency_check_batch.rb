# frozen_string_literal: true

require 'app_auth0_client'

class Auth0ConsistencyCheckBatch < ApplicationBatch
  Error = Class.new(StandardError)

  def initialize(sleep_duration: 1)
    @sleep_duration = sleep_duration
    super()
  end

  def run
    results = {
      only_auth0_ids: [],
      only_livelog_ids: [],
    }

    auth0_ids = User.pluck(:auth0_id)
    logger.info("LiveLog users total: #{auth0_ids.size}")

    i = 0
    loop do
      response = AppAuth0Client.instance.users(
        page: i,
        per_page: 100,
        include_totals: true,
        fields: 'user_id',
        q: %(identities.connection:"#{Auth0User::CONNECTION_NAME}"),
      )

      logger.info("Auth0 users total: #{response['total']}") if i.zero?
      logger.info("Start: #{response['start']}, Length: #{response['length']}")

      auth0_users = response['users'].map { |user| Auth0User.new(user) }

      auth0_users.each do |auth0_user|
        deleted_id = auth0_ids.delete(auth0_user.id)
        if deleted_id.nil?
          results[:only_auth0_ids] << auth0_user.id
        end
      end

      break if response['start'] + response['length'] >= response['total']

      i += 1
      sleep @sleep_duration # For rate limit
    end

    results[:only_livelog_ids] += auth0_ids

    if results.any? { |_, inconsistent_ids| !inconsistent_ids.empty? }
      raise Error, results.inspect
    end

    results
  end
end
