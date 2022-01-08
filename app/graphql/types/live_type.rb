# frozen_string_literal: true

module Types
  class LiveType < Types::BaseObject
    implements GraphQL::Types::Relay::Node
    global_id_field :id

    field :album_url, Types::HttpUrl, null: true, required_scope: 'read:lives'
    field :comment, String, null: true
    field :date, GraphQL::Types::ISO8601Date, null: false
    field :name, String, null: false
    field :place, String, null: true
    field :songs, Types::SongType.connection_type, null: false, max_page_size: nil
  end
end
