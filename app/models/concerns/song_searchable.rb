# frozen_string_literal: true

module SongSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_commit on: %i[create update] do
      __elasticsearch__.index_document if live.published?
    end

    after_commit on: %i[destroy] do
      __elasticsearch__.delete_document if live.published?
    end

    index_name "songs-#{Rails.env}" unless Rails.env.production?

    settings index: {
      number_of_shards: 1,
      number_of_replicas: 0,
      analysis: {
        analyzer: {
          default: {
            type: ENV.fetch('ELASTICSEARCH_DEFAULT_ANALYZER_TYPE', 'standard'),
            stopwords: '_english_',
          },
        },
      },
    }

    mapping dynamic: false do
      indexes :id, type: 'long'
      indexes :datetime, type: 'date'
      indexes :position, type: 'short'
      indexes :name, type: 'text' do
        indexes :raw, type: 'keyword'
      end
      indexes :artist, type: 'text' do
        indexes :raw, type: 'keyword'
      end
      indexes :visibility, type: 'keyword'
      indexes :has_media, type: 'boolean'
      indexes :original, type: 'boolean'
      indexes :players_count, type: 'byte'
      indexes :comment, type: 'text'
      indexes :players do
        indexes :member_id, type: 'integer'
        indexes :instruments, type: 'keyword'
      end
    end
  end

  def as_indexed_json(_options = {})
    {
      id: id,
      datetime: datetime.iso8601,
      position: position,
      name: name,
      artist: artist,
      visibility: visibility,
      has_media: youtube_id? || audio.attached?,
      original: original?,
      comment: comment,
      players_count: plays.size,
      players: plays.as_json(only: %i[member_id instruments], methods: [:instruments]),
    }
  end

  def more_like_this_query(size: 10)
    mlt_fields = %w[name.raw players.instruments]
    mlt_fields << 'artist.raw' if artist.present?

    Elasticsearch::DSL::Search.search do |q|
      # rubocop:disable Lint/ShadowingOuterLocalVariable
      q.query do |q|
        q.bool do |q|
          q.should do |q|
            q.more_like_this do |q|
              q.fields mlt_fields
              q.like _id: id
              q.min_term_freq 1
              q.min_doc_freq 2
            end
          end
          q.should { |q| q.term players_count: plays.size }
          q.should { |q| q.terms 'players.member_id': plays.map(&:member_id) }
          q.should { |q| q.term original: true } if original?
          q.must_not { |q| q.term visibility: 'only_players' }
        end
      end
      # rubocop:enable Lint/ShadowingOuterLocalVariable
      q.sort(
        _score: { order: :desc },
        datetime: { order: :desc },
      )
      q.size size
    end
  end

  module ClassMethods
    def basic_search_query(query)
      Elasticsearch::DSL::Search.search do |q|
        q.query do |q| # rubocop:disable Lint/ShadowingOuterLocalVariable
          q.multi_match query: query, fields: %w[name^2 artist^2 comment]
        end
        q.sort(
          _score: { order: :desc },
          datetime: { order: :desc },
          position: { order: :asc },
        )
      end
    end

    def advanced_search_query(name: nil, artist: nil, instruments: [], players_lower: nil, players_upper: nil, date_lower: nil, date_upper: nil,
                              original: false, has_media: false, excluded_instruments: [], logged_in: false)
      Elasticsearch::DSL::Search.search do |q|
        # rubocop:disable Lint/ShadowingOuterLocalVariable
        q.query do |q|
          q.bool do |q|
            q.must { |q| q.match name: name } if name.present?
            q.must { |q| q.match artist: artist } if artist.present?
            q.filter do |q|
              q.bool do |q|
                instruments.each do |instrument|
                  q.must { term 'players.instruments': instrument }
                end
                q.must do |q|
                  q.range :players_count do |q|
                    q.gte players_lower if players_lower
                    q.lte players_upper if players_upper
                  end
                end
                q.must do |q|
                  q.range :datetime do |q|
                    q.gte date_lower if date_lower
                    q.lte date_upper if date_upper
                  end
                end
                q.must { term original: true } if original
                q.must { term has_media: true } if has_media
                q.must { |q| q.term visibility: logged_in ? 'only_logged_in_users' : 'open' } if has_media
                q.must_not { |q| q.terms 'players.instruments': excluded_instruments } if excluded_instruments.present?
              end
            end
          end
        end
        # rubocop:enable Lint/ShadowingOuterLocalVariable
        q.sort(
          _score: { order: :desc },
          datetime: { order: :desc },
          position: { order: :asc },
        )
      end
    end
  end
end
