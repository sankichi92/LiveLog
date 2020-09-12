class Song
  class SearchQuery
    include ActiveModel::Model
    include Elasticsearch::DSL

    attr_accessor :q, :name, :artist, :instruments, :players_lower, :players_upper, :date_lower, :date_upper, :media, :original, :member_id, :ids, :logged_in

    validate :valid_date
    validates :players_lower, :players_upper, numericality: { only_integer: true }, allow_blank: true
    validates :media, inclusion: { in: %w[0 1] }, allow_blank: true
    validates :member_id, numericality: { only_integer: true }, allow_blank: true

    def to_hash
      return {} if invalid?

      search do |q|
        q.query do |q|
          q.bool do |q|
            q.must { |q| q.multi_match query: self.q, fields: %i[name artist comment] } if self.q.present?
            q.must { |q| q.match name: name } if name.present?
            q.must { |q| q.match artist: artist } if artist.present?
            q.filter do |q|
              q.bool do |q|
                included_instruments.each do |instrument|
                  q.must { term 'players.instruments': instrument }
                end
                q.must do |q|
                  q.range :players_count do |q|
                    q.gte players_lower.to_i if players_lower.present?
                    q.lte players_upper.to_i if players_upper.present?
                  end
                end
                q.must do |q|
                  q.range :datetime do |q|
                    q.gte date_lower.to_date if date_lower.present?
                    q.lte date_upper.to_date if date_upper.present?
                  end
                end
                q.must { |q| q.terms id: ids } if ids.present?
                q.must { term original?: true } if original?
                q.must { term media?: true } if media?
                q.must { |q| q.term visibility: logged_in ? 'only_logged_in_users' : 'open' } if media?
                q.must { |q| q.term 'players.member_id': member_id.to_i } if member_id.present?
                q.must_not { |q| q.terms 'players.instruments': excluded_instruments } if excluded_instruments.present?
              end
            end
          end
        end
        q.sort(
          _score: { order: :desc },
          datetime: { order: :desc },
          position: { order: :asc },
        )
        q.size ids.size if ids.present?
      end.to_hash
    end

    private

    def valid_date
      date_lower.to_date if date_lower.present?
      date_upper.to_date if date_upper.present?
    rescue ArgumentError
      errors.add(:date_lower, :invalid)
    end

    def instrument_arr
      instruments&.tr('&', ' ')&.split(' ') || []
    end

    def included_instruments
      instrument_arr.reject { |instrument| instrument.start_with?('-') }
    end

    def excluded_instruments
      instrument_arr.select { |instrument| instrument.start_with?('-') }.map { |instrument| instrument.sub('-', '') }
    end

    def media?
      media == '1'
    end

    def original?
      original == '1'
    end
  end
end
