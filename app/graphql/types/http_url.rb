module Types
  class HttpUrl < BaseScalar
    def self.coerce_input(input_value, context)
      uri = URI.parse(input_value)

      if uri.is_a?(URI::HTTP)
        uri
      else
        raise GraphQL::CoercionError, "#{input_value.inspect} is not an HTTP scheme URL"
      end
    rescue URI::InvalidURIError => e
      raise GraphQL::CoercionError, e.message
    end

    def self.coerce_result(ruby_value, context)
      ruby_value.to_s
    end
  end
end
