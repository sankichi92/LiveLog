module Types
  class LiveType < BaseObject
    field :id, ID, null: false
    field :date, GraphQL::Types::ISO8601Date, null: false
    field :name, String, null: false
    field :place, String, null: true
    field :comment, String, null: true
    field :album_url, HttpUrl, null: true, required_scope: 'read:lives'
    field :songs, SongType.connection_type, null: false, max_page_size: nil

    def songs
      BatchLoader::GraphQL.for(object.id).batch(default_value: []) do |live_ids, loader|
        Song.where(live_id: live_ids).played_order.each do |song|
          loader.call(song.live_id) { |memo| memo << song }
        end
      end
    end
  end
end
