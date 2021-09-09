# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

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

    # region Member

    field :member_joined_years, [Int], null: false
    field :members, MemberType.connection_type, null: false do
      argument :year, Int, required: true
    end
    field :member, MemberType, null: false do
      argument :id, ID, required: true
    end

    def member_joined_years
      Member.joined_years
    end

    def members(year:)
      Member.where(joined_year: year).order(plays_count: :desc)
    end

    def member(id:)
      Member.find(id)
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
