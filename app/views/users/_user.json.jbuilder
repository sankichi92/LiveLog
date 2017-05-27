json.extract! user, :id, :joined, :public
json.name user.full_name(logged_in?)
