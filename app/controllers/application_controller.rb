# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Session
  include RavenContext
end
