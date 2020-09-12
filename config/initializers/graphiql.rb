# frozen_string_literal: true

require 'app_auth0_client'

GraphiQL::Rails.config.tap do |config|
  config.title = 'LiveLog GraphiQL'
  config.logo = 'LiveLog GraphiQL'
  config.csrf = false
  config.headers['Authorization'] = lambda do |context|
    current_user = User.find_by(id: context.session[:user_id])
    cache_key = 'graphiql/access_token'

    access_token = if current_user&.auth0_credential&.valid_access_token
                     current_user.auth0_credential.valid_access_token
                   elsif Rails.cache.exist?(cache_key)
                     Rails.cache.read(cache_key)
                   else
                     auth0_api_token = AppAuth0Client.instance.api_token(audience: Rails.application.config.x.auth0.api_audience)
                     Rails.cache.write(cache_key, auth0_api_token.token, expires_in: auth0_api_token.expires_in.seconds)
                     auth0_api_token.token
                   end

    "Bearer #{access_token}"
  end
  config.initial_query = <<~GRAPHQL
    # LiveLog GraphiQL へようこそ！
    #
    # ここでは LiveLog GraphQL API を試すことができます。
    # LiveLog GraphQL API については https://github.com/sankichi92/LiveLog/wiki をご覧ください。
    #
    query {
      lives(first: 3) {
        pageInfo {
          hasNextPage
          endCursor
        }
        edges {
          cursor
          node {
            id
            date
            name
            place
            songs(first: 3) {
              totalCount
              nodes {
                id
                order
                name
                artist
                original
                players {
                  edges {
                    instrument
                    node {
                      id
                      joinedYear
                      name
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  GRAPHQL
end
