# frozen_string_literal: true

module GraphqlHelper
  def graphql_context(user: nil, client: nil, scope: nil)
    controller = instance_double(API::GraphqlController).tap do |double|
      allow(double).to receive(:url_for) { |options| "https://example.com/url_for/#{options}" }
    end

    {
      controller: controller,
      auth_payload: {
        scope: scope,
      },
      current_user: user,
      current_client: client,
    }
  end
end
