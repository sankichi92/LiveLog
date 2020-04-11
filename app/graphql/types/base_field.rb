module Types
  class BaseField < GraphQL::Schema::Field
    argument_class Types::BaseArgument

    attr_reader :required_scope

    def initialize(*args, required_scope: nil, **kwargs, &block)
      @required_scope = required_scope
      super(*args, **kwargs, &block)
    end

    def visible?(context)
      super && context.scope?(required_scope)
    end
  end
end
