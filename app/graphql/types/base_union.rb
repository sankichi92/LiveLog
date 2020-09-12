# frozen_string_literal: true

module Types
  class BaseUnion < GraphQL::Schema::Union
    connection_type_class Types::BaseConnection
    edge_type_class Types::BaseEdge
  end
end
