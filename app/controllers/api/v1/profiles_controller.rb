class Api::V1::ProfilesController < Api::V1::ApplicationController
  before_action :authenticated_user

  def show
    #
  end

  def update
    @current_user.update(profile_params)
    render :show
  end

  def profile_params
    params.permit(:nickname, :url, :intro, :public)
  end
end
