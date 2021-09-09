# frozen_string_literal: true

module Types
  class MemberType < Types::BaseObject
    class AvatarSize < BaseEnum
      value 'SMALL', '64x64', value: :small
      value 'MEDIUM', '192x192', value: :medium
      value 'LARGE', '384x384', value: :large
    end

    implements GraphQL::Types::Relay::Node
    global_id_field :id

    field :joined_year, Int, null: false
    field :name, String, null: false
    field :url, Types::HttpUrl, null: true
    field :bio, String, null: true
    field :avatar_url, Types::HttpUrl, null: true do
      argument :size, AvatarSize, required: false
    end
    field :played_instruments, [String], null: false
    field :played_songs, Types::PlayedSongConnection, null: false

    def avatar_url(size: :small)
      Loaders::AssociationLoader.for(Member, :avatar).load(object).then do |avatar|
        avatar.image_url(size: size)
      end
    end

    def played_songs
      object.plays.joins(:song).merge(Song.published.newest_live_order)
    end
  end
end
