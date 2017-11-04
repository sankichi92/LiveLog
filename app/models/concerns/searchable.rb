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

    def as_indexed_json(options = {})
      as_json(
        only: %i[id order name artist status],
        methods: %i[youtube_id? live_name datetime playings_size],
        include: {
          playings: {
            only: %i[inst user_id]
          }
        }
      )
    end

    def self.search(query)
      __elasticsearch__.search(
        sort: [
          { datetime: :desc },
          { order: :asc }
        ],
        query: {
          bool: {
            should: [
              { match_phrase: { name: query } },
              { match_phrase: { artist: query } }
            ]
          }
        }
      )
    end
  end
end
