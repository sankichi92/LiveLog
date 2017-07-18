json.array! @lives do |live|
  json.cache! ['v1', live] do
    json.partial! 'api/v1/lives/live', live: live
  end
end
