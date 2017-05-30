json.array! @lives do |live|
  json.cache! live do
    json.partial! 'lives/live', live: live
  end
end
