class Song
  class MoreLikeThisQuery
    include Elasticsearch::DSL

    delegate :id, :original?, :playings, to: :@song

    def initialize(song)
      @song = song
    end

    def to_hash
      search do |q|
        q.query do |q|
          q.bool do |q|
            q.should do |q|
              q.more_like_this do |q|
                q.fields %i[name artist players.instruments]
                q.like _id: id
                q.min_term_freq 1
                q.min_doc_freq 2
              end
            end
            q.should { |q| q.term players_count: playings.size }
            q.should { |q| q.terms 'players.user_id': playings.map(&:user_id) }
            q.should { |q| q.term original?: original? } if original?
            q.must_not { |q| q.term id: id }
            q.must_not { |q| q.term status: 'secret' }
          end
        end
      end.to_hash
    end
  end
end
