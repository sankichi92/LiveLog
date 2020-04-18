require 'app_auth0_client'

GraphiQL::Rails.config.tap do |config|
  config.title = 'LiveLog GraphQL API'
  config.logo = 'LiveLog GraphQL API'
  config.csrf = false
  config.headers['Authorization'] = lambda do |context|
    cookies = Rails.env.production? ? context.cookies.encrypted : context.cookies

    access_token = if cookies[:graphiql_access_token].present?
                     cookies[:graphiql_access_token]
                   else
                     api_token = AppAuth0Client.instance.api_token(audience: Rails.application.config.x.auth0.api_audience)
                     cookies[:graphiql_access_token] = { value: api_token.token, expires: api_token.expires_in.seconds }
                     api_token.token
                   end

    "Bearer #{access_token}"
  end
end
