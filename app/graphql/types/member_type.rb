module Types
  class MemberType < BaseObject
    class AvatarSize < BaseEnum
      value 'SMALL', '64x64', value: 64
      value 'MEDIUM', '192x192', value: 192
      value 'LARGE', '384x384', value: 384
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

    def avatar_url(size: 64)
      BatchLoader::GraphQL.for(object.id).batch do |member_ids, loader|
        Avatar.where(member_id: member_ids).each do |avatar|
          loader.call(avatar.member_id, avatar.image_url(size))
        end
      end
    end

    def played_songs
      BatchLoader::GraphQL.for(object.id).batch(default_value: []) do |member_ids, loader|
        songs = Song.published.joins(:plays).merge(Play.where(member_id: member_ids)).newest_live_order.select('songs.*', 'plays.member_id', 'plays.instrument')
        songs.each do |song|
          loader.call(song.member_id) { |memo| memo << song }
        end
      end
    end
  end
end
