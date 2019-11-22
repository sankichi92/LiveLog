class Song
  class MoreLikeThisQuery
    include Elasticsearch::DSL

    attr_reader :song, :size

    def initialize(song, size:)
      @song = song
      @size = size
    end

    def to_hash
      search do |q|
        q.query do |q|
          q.bool do |q|
            q.should do |q|
              q.more_like_this do |q|
                q.fields mlt_fields
                q.like _id: song.id
                q.min_term_freq 1
                q.min_doc_freq 2
              end
            end
            q.should { |q| q.term players_count: song.playings.size }
            q.should { |q| q.terms 'players.user_id': song.playings.map(&:member_id) }
            q.should { |q| q.term original?: song.original? } if song.original?
            q.must_not { |q| q.term id: song.id }
            q.must_not { |q| q.term status: 'secret' }
          end
        end
        q.sort(
          _score: { order: :desc },
          datetime: { order: :desc },
        )
        q.size size
      end.to_hash
    end

    private

    def mlt_fields
      %i[name.raw players.instruments].tap do |fields|
        fields << :'artist.raw' if song.artist.present?
      end
    end
  end
end
