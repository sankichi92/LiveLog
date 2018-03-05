module Concerns
  module Song
    module Searchable
      extend ActiveSupport::Concern

      included do
        include Elasticsearch::Model

        after_commit on: [:create] do
          __elasticsearch__.index_document if published?
        end

        after_commit on: [:update] do
          __elasticsearch__.update_document if published?
        end

        after_commit on: [:destroy] do
          __elasticsearch__.delete_document if published?
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

      def as_indexed_json(options = {})
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
    end
  end
end
