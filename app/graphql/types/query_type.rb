module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :lives, LiveType.connection_type, null: false, max_page_size: 30do
      argument :year, Int, required: false, description: 'Returns lives that held in the year'
    end
    field :live, LiveType, null: false do
      argument :id, ID, required: true
    end

    def lives(year: nil)
      if year
        Live.published.nendo(year).newest_order
      else
        Live.published.newest_order
      end
    end

    def live(id:)
      Live.published.find(id)
    end
  end
end
