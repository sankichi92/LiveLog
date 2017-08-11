module Api::V1
  class ApplicationController < ActionController::API
    ANDROID_UA_PAT = %r{\ALiveLog-Android\/(?<version>\d+(?:\.\d+)+) \(Android (?<android_version>\d+(?:\.\d+)+); (?<brand>.+) (?<model>.+)\)\z}

    include ActionController::Caching
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include Api::V1::TokensHelper

    before_action :check_user_agent if Rails.env == 'production'
    before_action :authenticate

    private

    def check_user_agent
      user_agent = request.user_agent
      render status: :forbidden unless user_agent.match(ANDROID_UA_PAT)
    end

    def authenticate
      authenticate_with_http_token do |token, options|
        user = User.find_by(id: options[:id])
        @current_user = user if user.valid_token?(token)
        @token = token
      end
    end

    def authenticated_user
      request_http_token_authentication unless authenticated?
    end
  end
end
