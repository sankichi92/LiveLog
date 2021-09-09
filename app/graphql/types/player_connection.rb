# frozen_string_literal: true

module Types
  class PlayerConnection < BaseConnection
    class Edge < BaseEdge
      graphql_name 'PlayerEdge'
      node_type MemberType

      field :instrument, String, null: true

      def instrument
        object.node.instrument
      end

      def node
        Loaders::AssociationLoader.for(Play, :member).load(object.node)
      end
    end

    edge_type Edge

    def nodes
      Loaders::AssociationLoader.for(Play, :member).load_many(object.nodes)
    end
  end
end
