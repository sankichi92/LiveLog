json.extract! playing, :inst
json.user do
  json.partial! 'users/user', user: playing.user
end
