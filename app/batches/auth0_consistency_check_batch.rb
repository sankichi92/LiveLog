require 'app_auth0_client'

class Auth0ConsistencyCheckBatch < ApplicationBatch
  Error = Class.new(StandardError)

  def initialize(sleep_duration: 1)
    @sleep_duration = sleep_duration
  end

  def run
    results = {
      inconsistent_auth0_ids: [],
      inconsistent_livelog_ids: [],
    }

    user_ids = User.where(password_digest: nil).pluck(:id)
    logger.info("LiveLog users total: #{user_ids.size}")

    i = 0
    begin
      response = AppAuth0Client.instance.users(
        page: i,
        per_page: 100,
        include_totals: true,
        fields: 'user_id',
        q: %(identities.connection:"#{Auth0User::CONNECTION_NAME}"),
      )

      logger.info("Auth0 users total: #{response['total']}") if i == 0
      logger.info("Start: #{response['start']}, Length: #{response['length']}")

      auth0_users = response['users'].map { |user| Auth0User.new(user) }

      auth0_users.each do |auth0_user|
        deleted_id = user_ids.delete(auth0_user.livelog_id)
        if deleted_id.nil?
          results[:inconsistent_auth0_ids] << auth0_user.id
        end
      end

      i += 1
      sleep @sleep_duration # For rate limit
    end while response['start'] + response['length'] < response['total']

    results[:inconsistent_livelog_ids] += user_ids

    if results.any? { |_, inconsistent_ids| !inconsistent_ids.empty? }
      raise Error, results.inspect
    end

    results
  end
end
