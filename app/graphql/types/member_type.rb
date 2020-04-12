module Types
  class MemberType < Types::BaseObject
    field :id, ID, null: false
    field :joined_year, Int, null: false
    field :name, String, null: false
    field :url, HttpUrl, null: true
    field :bio, String, null: true
    field :played_songs, PlayedSongConnection, null: false

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
