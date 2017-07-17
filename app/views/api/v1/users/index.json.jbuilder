json.array! @users do |user|
  json.cache! user do
    json.partial! 'api/v1/users/user', user: user
  end
end
