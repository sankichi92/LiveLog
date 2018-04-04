json.extract! user, :id, :joined, :public
json.name authenticated? ? user.name_with_handle : user.handle
