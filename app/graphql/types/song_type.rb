module Types
  class SongType < Types::BaseObject
    field :id, ID, null: false
    field :live, Types::LiveType, null: false
    field :time, String, null: true, method: :time_str
    field :order, Integer, null: false, method: :position
    field :name, String, null: false
    field :artist, String, null: true
    field :original, Boolean, null: false
    field :comment, String, null: true
    field :youtube_url, HttpUrl, null: true, authorization: ->(object, args, context) { video_visible?(object, args, context) }

    def self.video_visible?(song, _args, context)
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
      BatchLoader::GraphQL.for(object.live_id).batch do |live_ids, loader|
        Live.where(id: live_ids).each { |live| loader.call(live.id, live) }
      end
    end
  end
end
