# frozen_string_literal: true

module Types
  class LiveType < BaseObject
    implements GraphQL::Types::Relay::Node
    global_id_field :id

    field :date, GraphQL::Types::ISO8601Date, null: false
    field :name, String, null: false
    field :place, String, null: true
    field :comment, String, null: true
    field :album_url, HttpUrl, null: true, required_scope: 'read:lives'
    field :songs, SongType.connection_type, null: false, max_page_size: nil

    def songs
      Loaders::AssociationLoader.for(Live, :songs).load(object)
    end
  end
end
