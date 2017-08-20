class StaticPagesController < ApplicationController
  def home
    #
  end

  def stats
    range = if params[:y] && Live.years.include?(params[:y].to_i)
              start = Date.new(params[:y].to_i, 4, 1)
              (start...start + 1.year)
            else
              (1.year.ago..Time.zone.today)
            end

    @songs = Song.includes(:live).where('lives.date' => range)
    @playings = Playing.includes(song: :live).where('lives.date' => range)
  end
end
