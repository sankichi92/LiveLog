class SongsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_or_elder_user, only: %i(new create destroy)

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
