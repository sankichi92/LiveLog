class Stats
  include ActiveModel::Validations

  attr_reader :year

  validate :year_must_be_included_in_live_years

  def initialize(year)
    @year = year
  end

  def date_range
    @date_range ||= Date.new(year, 4, 1)..Date.new(year + 1, 3, 31)
  end

  def number_of_songs
    songs.count
  end

  def number_of_players
    playings.distinct.count(:user_id)
  end

  def inst_to_count
    playings.count_by_divided_instrument
  end

  def number_of_artists
    songs.where.not(artist: '').distinct.count(:artist)
  end

  def top10_artist_to_count
    return @top10_artists unless @top10_artists.nil?
    results = []
    previous_count = 0
    songs.where.not(artist: '').group(:artist).count.select { |_, c| c >= 2 }.sort { |(_, c1), (_, c2)| c2 <=> c1 }.each_with_index do |(artist, count), i|
      break if i >= 10 && count < previous_count
      results << [artist, count]
      previous_count = count
    end
    @top10_artists = results.to_h
  end

  def formation_to_count
    playings.count_formations
  end

  def average_formation
    (formation_to_count.inject(0) { |sum, (f, c)| sum += f * c } / number_of_songs.to_f).round(2)
  end

  private

  def year_must_be_included_in_live_years
    unless Live.years.include?(year)
      errors.add(:year, :inclusion)
    end
  end

  def songs
    Song.published.includes(:live).where('lives.date': date_range)
  end

  def playings
    Playing.includes(song: :live).merge(Live.published).where('lives.date': date_range)
  end
end
