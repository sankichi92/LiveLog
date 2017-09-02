json.token @token.token
json.user do
  json.partial! 'api/v1/profiles/profile', user: @current_user
end
