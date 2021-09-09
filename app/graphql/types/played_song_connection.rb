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

      def node
        Loaders::AssociationLoader.for(Play, :song).load(object.node)
      end
    end

    edge_type Edge

    def nodes
      Loaders::AssociationLoader.for(Play, :song).load_many(object.nodes)
    end
  end
end
