module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    def as_indexed_json(options = {})
      as_json(
        only: %i[id name artist status],
        methods: %i[youtube_id? live_name date playings_count],
        include: {
          playings: {
            only: %i[inst user_id]
          }
        }
      )
    end

    def self.search(query)
      __elasticsearch__.search(
        sort: [{ date: :desc }],
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
