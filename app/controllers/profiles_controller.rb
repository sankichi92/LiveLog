class ProfilesController < ApplicationController
  before_action :require_current_user

  def edit
    redirect_to edit_user_url(current_user)
  end
end
