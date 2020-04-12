module Types
  class PlayerConnection < BaseConnection
    class Edge < BaseEdge
      graphql_name 'PlayerEdge'
      node_type MemberType

      field :instrument, String, null: true

      def instrument
        object.node.instrument
      end
    end

    edge_type Edge
  end
end
