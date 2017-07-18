json.array! @users do |user|
  json.cache_if! !authenticated?, ['v1', user] do
    json.partial! 'api/v1/users/user', user: user
  end
end
