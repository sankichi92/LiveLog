# frozen_string_literal: true

module API
  class GraphqlController < APIController
    # rubocop:disable Naming/MethodParameterName, Naming/VariableName
    def execute(query = nil, variables = {}, operationName = nil)
      context = {
        controller: self,
        auth_payload: auth_payload,
        current_user: current_user,
        current_client: current_client,
      }
      result = LiveLogSchema.execute(query, variables: ensure_hash(variables), context: context, operation_name: operationName)
      render json: result
    end
    # rubocop:enable Naming/MethodParameterName, Naming/VariableName

    private

    # Handle form data, JSON body, or a blank value
    def ensure_hash(ambiguous_param)
      case ambiguous_param
      when String
        if ambiguous_param.present?
          ensure_hash(JSON.parse(ambiguous_param))
        else
          {}
        end
      when Hash, ActionController::Parameters
        ambiguous_param
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
      end
    end
  end
end
