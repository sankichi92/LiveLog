# frozen_string_literal: true

module Types
  class BaseField < GraphQL::Schema::Field
    argument_class Types::BaseArgument

    attr_reader :required_scope, :authorization

    def initialize(*, required_scope: nil, authorization: nil, **, &)
      @required_scope = required_scope
      @authorization = authorization
      super(*, **, &)
    end

    def visible?(context)
      super && (required_scope.blank? || context.scope?(required_scope))
    end

    def authorized?(object, args, context)
      super && (authorization.nil? || authorization.call(object, args, context))
    end
  end
end
