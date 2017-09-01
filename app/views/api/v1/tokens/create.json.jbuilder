json.token @token.token
json.user do
  json.extract! @current_user, :id, :email, :joined, :public, :nickname, :url, :intro
  json.name @current_user.full_name
end
