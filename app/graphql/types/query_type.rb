# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    # region Live

    field :live, Types::LiveType, null: false do
      argument :id, ID, required: true, loads: LiveType, as: :live
    end
    field :lives, Types::LiveType.connection_type, null: false do
      argument :year, Int, required: false
    end

    def lives(year: nil)
      if year
        Live.published.nendo(year).newest_order
      else
        Live.published.newest_order
      end
    end

    def live(live:)
      live
    end

    # endregion

    # region Member

    field :member, Types::MemberType, null: false do
      argument :id, ID, required: true, loads: MemberType, as: :member
    end
    field :member_joined_years, [Int], null: false
    field :members, Types::MemberType.connection_type, null: false do
      argument :year, Int, required: true
    end

    def member_joined_years
      Member.joined_years
    end

    def members(year:)
      Member.where(joined_year: year).order(plays_count: :desc)
    end

    def member(member:)
      member
    end

    # endregion

    # region Song

    field :song, Types::SongType, null: false do
      argument :id, ID, required: true, loads: SongType, as: :song
    end

    def song(song:)
      song
    end

    # endregion
  end
end
