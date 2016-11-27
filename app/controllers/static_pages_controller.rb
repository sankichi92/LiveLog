class StaticPagesController < ApplicationController
  def home
    @songs = Song.paginate(page: params[:page], per_page: 20)
  end

  def stats
    if params[:y]
      start = Date.new(params[:y].to_i, 4, 1)
      range = (start...start + 1.year)
    else
      stop = Date.today
      range = (stop - 1.year..stop)
    end

    @songs = Song.unscoped.includes(:live).where('lives.date': range)
    @playings = Playing.includes(song: :live).where('lives.date': range)
  end
end
