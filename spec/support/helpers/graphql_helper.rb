module GraphqlHelper
  def graphql_context(user: nil, client: nil, scope: nil)
    {
      auth_payload: {
        scope: scope,
      },
      current_user: user,
      current_client: client,
    }
  end
end
