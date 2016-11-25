class StaticPagesController < ApplicationController
  def home
    @songs = Song.paginate(page: params[:page])
  end

  def about
  end
end
