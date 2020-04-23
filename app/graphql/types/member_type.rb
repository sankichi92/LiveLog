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
      BatchLoader::GraphQL.for(object).batch do |members, loader|
        ActiveRecord::Associations::Preloader.new.preload(members, [:user, { avatar_attachment: :blob }])
        members.each do |member|
          url = if member.avatar.attached? && member.avatar.variable?
                  context.url_for(member.avatar.variant(resize_to_fill: [size, size]))
                elsif member.user&.activated?
                  "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(object.user.email)}?s=#{size}&d=mm"
                end
          loader.call(member, url) if url
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
