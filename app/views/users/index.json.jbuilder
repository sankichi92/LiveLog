json.array! @users do |user|
  json.cache! user do
    json.partial! 'users/user', user: user
  end
end
