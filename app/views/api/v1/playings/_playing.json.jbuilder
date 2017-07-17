json.extract! playing, :inst
json.user playing.user, partial: 'api/v1/users/user', as: :user
