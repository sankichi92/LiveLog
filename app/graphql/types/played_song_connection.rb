# frozen_string_literal: true

module Types
  class PlayedSongConnection < BaseConnection
    class Edge < BaseEdge
      graphql_name 'PlayedSongEdge'
      node_type SongType

      field :instrument, String, null: true

      def instrument
        object.node.instrument
      end
    end

    edge_type Edge
  end
end
