module Searchable
  extend ActiveSupport::Concern
  include Elasticsearch::DSL

  included do
    include Elasticsearch::Model

    after_commit on: [:create] do
      __elasticsearch__.index_document if published?
    end

    after_commit on: [:update] do
      __elasticsearch__.update_document if published?
    end

    after_commit on: [:destroy] do
      __elasticsearch__.delete_document if published?
    end

    settings index: {
      number_of_shards: 1,
      number_of_replicas: 0,
      analysis: {
        analyzer: {
          default: {
            type: 'kuromoji',
            stopwords: '_english_'
          }
        }
      }
    }

    mapping dynamic: false, _all: { enabled: false } do
      indexes :id, type: 'integer'
      indexes :live_name, type: 'text', index: 'no'
      indexes :datetime, type: 'date'
      indexes :order, type: 'short'
      indexes :name, type: 'text'
      indexes :artist, type: 'text'
      indexes :status, type: 'keyword'
      indexes :has_video?, type: 'boolean'
      indexes :players_count, type: 'byte'
      indexes :players do
        indexes :user_id, type: 'integer', index: 'no'
        indexes :instruments, type: 'keyword'
      end
    end
  end

  def as_indexed_json(options = {})
    {
      id: id,
      live_name: live_name,
      datetime: datetime,
      order: order,
      name: name,
      artist: artist,
      status: status,
      has_video?: youtube_id?,
      players_count: playings_size,
      players: playings.as_json(only: %i[user_id instruments], methods: [:instruments])
    }
  end

  class_methods do
    def basic_search(query)
      definition = Search.new do
        query do
          multi_match query: query, fields: %i[name artist]
        end
        sort _score: { order: :desc },
             datetime: { order: :desc },
             order: { order: :asc }
      end
      __elasticsearch__.search(definition)
    end

    def advanced_search(params, logged_in)
      instruments = params[:instruments].tr('&', ' ').split(' ')
      rejected_insts = instruments.select { |inst| inst.start_with?('-') }.map { |inst| inst.sub('-', '') }
      selected_insts = instruments.reject { |inst| inst.start_with?('-') }

      if params[:has_video] == '1'
        has_video = true
        status = logged_in ? 'closed' : 'open'
      end

      definition = Search.new do
        query do
          bool do
            must do
              match name: params[:name] if params[:name].present?
            end
            must do
              match artist: params[:artist] if params[:artist].present?
            end
            filter do
              bool do
                selected_insts.each do |inst|
                  must do
                    term 'players.instruments': inst
                  end
                end
                must do
                  range :players_count do
                    gte params[:players_lower] if params[:players_lower].present?
                    lte params[:players_upper] if params[:players_upper].present?
                  end
                end
                must do
                  range :datetime do
                    gte params[:date_lower] if params[:date_lower].present?
                    lte params[:date_upper] if params[:date_upper].present?
                  end
                end
                must do
                  term has_video?: has_video if has_video.present?
                end
                must do
                  term status: status if status.present?
                end
                must_not do
                  terms 'players.instruments': rejected_insts if rejected_insts.present?
                end
              end
            end
          end
        end
        sort _score: { order: :desc },
             datetime: { order: :desc },
             order: { order: :asc }
      end
      __elasticsearch__.search(definition)
    end
  end
end
