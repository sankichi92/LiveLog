module Concerns
  module Song
    module Searchable
      extend ActiveSupport::Concern

      included do
        include Elasticsearch::Model

        after_commit on: %i[create update] do
          __elasticsearch__.index_document if published?
        end

        after_commit on: %i[destroy] do
          __elasticsearch__.delete_document if published?
        end

        if Rails.env.test?
          index_name 'songs-test'
        end

        settings index: {
          number_of_shards: 1,
          number_of_replicas: 0,
          analysis: {
            analyzer: {
              default: {
                type: 'kuromoji',
                stopwords: '_english_'
              }
            }
          }
        }

        mapping dynamic: false, _all: { enabled: false } do
          indexes :id, type: 'integer'
          indexes :live_name, type: 'text', index: false
          indexes :datetime, type: 'date'
          indexes :order, type: 'short'
          indexes :name, type: 'text'
          indexes :artist, type: 'text'
          indexes :status, type: 'keyword'
          indexes :has_video?, type: 'boolean'
          indexes :original?, type: 'boolean'
          indexes :players_count, type: 'byte'
          indexes :players do
            indexes :user_id, type: 'integer'
            indexes :instruments, type: 'keyword'
          end
        end
      end

      def as_indexed_json(_options = {})
        {
          id: id,
          live_name: live_name,
          datetime: datetime,
          order: order,
          name: name,
          artist: artist,
          status: status,
          has_video?: youtube_id?,
          original?: original?,
          players_count: playings_size,
          players: playings.as_json(only: %i[user_id instruments], methods: [:instruments])
        }
      end

      def more_like_this
        self.class.search(::Song::MoreLikeThisQuery.new(self))
      end
    end
  end
end
