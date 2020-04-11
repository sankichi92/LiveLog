module Types
  class LiveType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :date, GraphQL::Types::ISO8601Date, null: false
    field :place, String, null: true
    field :comment, String, null: true
  end
end
