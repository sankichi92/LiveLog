module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    # region Live

    field :lives, LiveType.connection_type, null: false
    field :live, LiveType, null: false do
      argument :id, ID, required: true
    end

    def lives
      Live.published.newest_order
    end

    def live(id:)
      Live.published.find(id)
    end

    # endregion

    # region Song

    field :songs, SongType.connection_type, null: false
    field :song, SongType, null: false do
      argument :id, ID, required: true
    end

    def songs
      Song.published.newest_live_order
    end

    def song(id:)
      Song.published.find(id)
    end

    # endregion
  end
end
