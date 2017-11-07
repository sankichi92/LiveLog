class Song
  class Search
    include ActiveModel::Model
    include Elasticsearch::DSL
    extend ActiveModel::Naming

    attr_accessor :q, :name, :artist, :instruments, :excluded_instruments, :players_lower, :players_upper, :date_lower,
                  :date_upper, :video, :user_id, :ids

    validate :valid_date
    validates :players_lower, :players_upper, numericality: { only_integer: true }, allow_blank: true
    validates :video, inclusion: { in: %w[0 1] }, allow_blank: true
    validates :user_id, numericality: { only_integer: true }, allow_blank: true

    def to_payload(logged_in = false)
      return {} if invalid?
      search do |q|
        q.query do |q|
          q.bool do |q|
            q.must { |q| q.multi_match query: self.q, fields: %i[name artist] } if self.q.present?
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
                q.must { |q| q.term has_video?: video? } if video?
                q.must { |q| q.term status: logged_in ? 'closed' : 'open' } if video?
                q.must { |q| q.term 'players.user_id': user_id.to_i } if user_id.present?
                q.must_not { |q| q.terms 'players.instruments': excluded_instruments } if excluded_instruments.present?
              end
            end
          end
        end
        q.sort(
          _score: { order: :desc },
          datetime: { order: :desc },
          order: { order: :asc }
        )
        q.size ids.size if ids.present?
      end
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
      instrument_arr.reject { |inst| inst.start_with?('-') }
    end

    def excluded_instruments
      instrument_arr.select { |inst| inst.start_with?('-') }.map { |inst| inst.sub('-', '') }
    end

    def video?
      video == '1'
    end
  end
end
