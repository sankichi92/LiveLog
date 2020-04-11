class CustomContext < GraphQL::Query::Context
  def auth_payload
    self[:auth_payload]
  end

  def current_user
    self[:current_user]
  end
end
