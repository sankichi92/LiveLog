class LiveLogSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  context_class CustomContext

  # Opt in to the new runtime (default in future graphql-ruby versions)
  use GraphQL::Execution::Interpreter
  use GraphQL::Analysis::AST

  # Add built-in connections for pagination
  use GraphQL::Pagination::Connections
end
