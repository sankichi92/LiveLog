module GraphqlHelper
  def graphql_context(user: nil, scope: nil)
    {
      auth_payload: {
        scope: scope,
      },
      current_user: user,
    }
  end
end
