module Types
  module BaseInterface
    include GraphQL::Schema::Interface

    field_class Types::BaseField
    connection_type_class Types::BaseConnection
  end
end
