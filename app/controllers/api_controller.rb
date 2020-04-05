class APIController < ActionController::API
  include JWTAuthentication
  include RavenContext
end
