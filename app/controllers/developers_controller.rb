class DevelopersController < ApplicationController
  before_action :require_current_user

  def show
    @developer = current_user.developer
  end
end
