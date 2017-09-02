json.token @token.token
json.user do
  json.partial! 'profiles/profile', user: @current_user
end
