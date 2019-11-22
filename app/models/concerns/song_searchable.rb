module SongSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_commit on: %i[create update] do
      __elasticsearch__.index_document if live.published?
    end

    after_commit on: %i[destroy] do
      __elasticsearch__.delete_document if live.published?
    end

    if Rails.env.test?
      index_name 'songs-test'
    end

    settings index: {
      number_of_shards: 1,
      number_of_replicas: 0,
      analysis: {
        analyzer: {
          default: {
            type: 'kuromoji',
            stopwords: '_english_',
          },
        },
      },
    }

    mapping dynamic: false do
      indexes :id, type: 'integer'
      indexes :datetime, type: 'date'
      indexes :order, type: 'short'
      indexes :name, type: 'text' do
        indexes :raw, type: 'keyword'
      end
      indexes :artist, type: 'text' do
        indexes :raw, type: 'keyword'
      end
      indexes :status, type: 'keyword'
      indexes :has_video?, type: 'boolean'
      indexes :audio_attached?, type: 'boolean'
      indexes :original?, type: 'boolean'
      indexes :players_count, type: 'byte'
      indexes :comment, type: 'text'
      indexes :players do
        indexes :member_id, type: 'integer'
        indexes :instruments, type: 'keyword'
      end
    end
  end

  def as_indexed_json(_options = {})
    {
      id: id,
      datetime: datetime,
      order: order,
      name: name,
      artist: artist,
      status: status,
      has_video?: youtube_id?,
      audio_attached?: audio.attached?,
      original?: original?,
      comment: comment,
      players_count: playings.size,
      players: playings.as_json(only: %i[member_id instruments], methods: [:instruments]),
    }
  end

  def more_like_this(size: 10)
    self.class.search ::Song::MoreLikeThisQuery.new(self, size: size)
  end
end
