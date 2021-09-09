# frozen_string_literal: true

module Types
  class SongType < BaseObject
    field :id, ID, null: false
    field :live, LiveType, null: false
    field :time, String, null: true, method: :time_str
    field :order, Integer, null: false, method: :position
    field :name, String, null: false
    field :artist, String, null: true
    field :original, Boolean, null: false
    field :comment, String, null: true
    field :youtube_url, HttpUrl, null: true, authorization: ->(object, args, context) { audio_visual_visible?(object, args, context) }
    field :audio_url, HttpUrl, null: true, authorization: ->(object, args, context) { audio_visual_visible?(object, args, context) }
    field :players, PlayerConnection, null: false, max_page_size: nil

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

    def players
      # TODO
      Member.joins(:plays).merge(Play.where(song_id: object.id)).select('members.*', 'plays.song_id', 'plays.instrument')
    end
  end
end
