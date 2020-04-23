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
      BatchLoader::GraphQL.for(object.live_id).batch do |live_ids, loader|
        Live.where(id: live_ids).each { |live| loader.call(live.id, live) }
      end
    end

    def audio_url
      BatchLoader::GraphQL.for(object).batch do |songs, loader|
        ActiveRecord::Associations::Preloader.new.preload(songs, { audio_attachment: :blob })
        songs.each do |song|
          loader.call(song, context.url_for(song.audio)) if song.audio.attached?
        end
      end
    end

    def players
      BatchLoader::GraphQL.for(object.id).batch(default_value: []) do |song_ids, loader|
        Member.joins(:plays).merge(Play.where(song_id: song_ids)).select('members.*', 'plays.song_id', 'plays.instrument').each do |member|
          loader.call(member.song_id) { |memo| memo << member }
        end
      end
    end
  end
end
