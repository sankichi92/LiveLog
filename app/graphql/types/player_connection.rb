# frozen_string_literal: true

module Types
  class PlayerConnection < Types::BaseConnection
    class Edge < Types::BaseEdge
      graphql_name 'PlayerEdge'
      node_type Types::MemberType

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
