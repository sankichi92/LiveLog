# frozen_string_literal: true

module Types
  class MemberType < BaseObject
    class AvatarSize < BaseEnum
      value 'SMALL', '64x64', value: :small
      value 'MEDIUM', '192x192', value: :medium
      value 'LARGE', '384x384', value: :large
    end

    field :id, ID, null: false
    field :joined_year, Int, null: false
    field :name, String, null: false
    field :url, HttpUrl, null: true
    field :bio, String, null: true
    field :avatar_url, HttpUrl, null: true do
      argument :size, AvatarSize, required: false
    end
    field :played_instruments, [String], null: false
    field :played_songs, PlayedSongConnection, null: false

    def avatar_url(size: :small)
      Loaders::AssociationLoader.for(Member, :avatar).load(object).then do |avatar|
        avatar.image_url(size: size)
      end
    end

    def played_songs
      # TODO
      Song.published.joins(:plays).merge(Play.where(member_id: object.id)).newest_live_order.select('songs.*', 'plays.member_id', 'plays.instrument')
    end
  end
end
