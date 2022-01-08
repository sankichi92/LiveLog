# frozen_string_literal: true

module Types
  class SongType < Types::BaseObject
    implements GraphQL::Types::Relay::Node
    global_id_field :id

    field :artist, String, null: true
    field :audio_url, Types::HttpUrl, null: true, authorization: ->(object, args, context) { audio_visual_visible?(object, args, context) }
    field :comment, String, null: true
    field :live, Types::LiveType, null: false
    field :name, String, null: false
    field :order, Int, null: false, method: :position
    field :original, Boolean, null: false
    field :players, Types::PlayerConnection, null: false, max_page_size: nil, method: :plays
    field :time, String, null: true, method: :time_str
    field :youtube_url, Types::HttpUrl, null: true, authorization: ->(object, args, context) { audio_visual_visible?(object, args, context) }

    def self.audio_visual_visible?(song, _args, context)
      case song.visibility
      when 'open'
        true
      when 'only_logged_in_users'
        context.scope?('read:songs')
      else
        context.scope?('read:songs') && song.player?(context.current_user&.member)
      end
    end

    def live
      Loaders::AssociationLoader.for(Song, :live).load(object)
    end

    def audio_url
      Loaders::ActiveStorageLoader.for(:Song, :audio).load(object.id).then do |audio|
        context.url_for(audio)
      end
    end
  end
end
