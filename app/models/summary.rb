# frozen_string_literal: true

class Summary
  class Builder
    def initialize(year)
      @year = year
    end

    def build
      summary_hash = Rails.cache.fetch("summaries/20190120/#{@year}", expires_in: 1.day) do
        {
          lives_count: live_relation.count,
          songs_count: song_relation.count,
          members_count: play_relation.distinct.count(:member_id),
          instrument_to_count: play_relation.count_by_divided_instrument,
          original_songs_count: song_relation.where(original: true).count,
          covered_artists_count: song_relation.where(original: false).where.not(artist: '').distinct.count(:artist),
          top10_artist_to_count: top10_artist_to_count,
          formation_to_count: play_relation.count_formations,
        }
      end

      Summary.new(@year, **summary_hash)
    end

    private

    def top10_artist_to_count
      results = []
      previous_count = 0
      artist_to_count = song_relation.where.not(artist: [nil, '']).group(:artist).count
      artist_to_count.select { |_, c| c >= 2 }.sort { |(_, c1), (_, c2)| c2 <=> c1 }.each_with_index do |(artist, count), i|
        break if i >= 10 && count < previous_count

        results << [artist, count]
        previous_count = count
      end
      results.to_h
    end

    def song_relation
      Song.joins(:live).merge(live_relation)
    end

    def play_relation
      Play.joins(song: :live).merge(live_relation)
    end

    def live_relation
      Live.published.nendo(@year)
    end
  end

  attr_reader :year, :lives_count, :songs_count, :members_count, :instrument_to_count, :original_songs_count, :covered_artists_count, :top10_artist_to_count,
              :formation_to_count

  def initialize(year, lives_count:, songs_count:, members_count:, instrument_to_count:, original_songs_count:, covered_artists_count:, top10_artist_to_count:,
                 formation_to_count:)
    @year = year
    @lives_count = lives_count
    @songs_count = songs_count
    @members_count = members_count
    @instrument_to_count = instrument_to_count
    @original_songs_count = original_songs_count
    @covered_artists_count = covered_artists_count
    @top10_artist_to_count = top10_artist_to_count
    @formation_to_count = formation_to_count
  end

  def date_range
    Date.new(year, 4, 1)..Date.new(year + 1, 3, 31)
  end

  def formation_average
    (formation_to_count.inject(0) { |sum, (f, c)| sum += f * c } / songs_count.to_f).round(2)
  end
end
