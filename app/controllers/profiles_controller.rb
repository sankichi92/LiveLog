class ProfilesController < ApplicationController
  before_action :logged_in_user

  def edit
    redirect_to edit_user_url(current_user)
  end
end
