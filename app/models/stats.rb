class Stats
  include ActiveModel::Validations

  attr_reader :year, :date_range

  validates :year, inclusion: { in: Live.years }

  def initialize(year)
    @year = year
    @date_range = Date.new(year, 4, 1)..Date.new(year + 1, 3, 31)
  end

  def number_of_songs
    songs.count
  end

  def number_of_players
    playings.distinct.count(:user_id)
  end

  def inst_to_count
    playings.count_insts
  end

  def number_of_artists
    songs.where.not(artist: '').distinct.count(:artist)
  end

  def artist_to_count
    songs.where.not(artist: '').group(:artist).having('songs.count >= 5').count.sort { |(_, c1), (_, c2)| c2 <=> c1 }
  end

  def formation_to_count
    playings.count_formations
  end

  def average_formation
    (formation_to_count.inject(0) { |sum, (f, c)| sum += f * c } / number_of_songs.to_f).round(2)
  end

  private

  def songs
    Song.published.includes(:live).where('lives.date': date_range)
  end

  def playings
    Playing.published.includes(song: :live).where('lives.date': date_range)
  end
end
