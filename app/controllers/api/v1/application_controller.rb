module Api::V1
  class ApplicationController < ActionController::API
    include ActionController::Caching
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include Api::V1::TokensHelper

    before_action :authenticate

    private

    def authenticate
      authenticate_with_http_token do |token, options|
        user = User.find_by(id: options[:id])
        @current_user = user if user.authenticated?(:api, token)
      end
    end

    def authenticated_user
      request_http_token_authentication unless authenticated?
    end
  end
end
