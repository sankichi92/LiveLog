class StaticPagesController < ApplicationController
  before_action :logged_in_user, only: :donate

  def home
    @song = Song.includes(playings: :user).pickup
    @lives = Live.latest
  end

  def donate; end
end
