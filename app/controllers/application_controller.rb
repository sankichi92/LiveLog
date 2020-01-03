class ApplicationController < ActionController::Base
  include Session
  include RavenContext
end
