module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :lives, LiveType.connection_type, null: false, max_page_size: 30
    field :live, LiveType, null: false do
      argument :id, ID, required: true
    end

    def lives
      Live.published.newest_order
    end

    def live(id:)
      Live.published.find(id)
    end
  end
end
