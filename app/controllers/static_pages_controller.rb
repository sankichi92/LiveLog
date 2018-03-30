class StaticPagesController < ApplicationController
  before_action :logged_in_user, only: :donation

  def home
    @song = Song.includes(playings: :user).pickup
    @lives = Live.latest
  end

  def donation; end
end
