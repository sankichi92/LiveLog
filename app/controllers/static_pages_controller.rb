class StaticPagesController < ApplicationController
  def home
    @songs = Song.paginate(page: params[:page])
  end

  def stats
    if params[:y]
      start = Date.new(params[:y].to_i, 4, 1)
      range = (start...start + 1.year)
    else
      stop = Date.today
      range = (stop - 1.year..stop)
    end

    songs = Song.unscoped.includes(:live).where('lives.date': range)
    @count = songs.count
    @artists = songs.group(:artist).count.sort { |(k1, v1), (k2, v2)| v2 <=> v1 }

    playings = Playing.includes(song: :live).where('lives.date': range)
    @member_count = playings.group(:user_id).count
    @insts = Playing.resolve_insts(playings.count_insts)
    @formations = Playing.count_formation(playings.count_members)
  end
end
