json.extract! user, :id, :joined, :public
json.name user.display_name(authenticated?)
