# frozen_string_literal: true

if ENV['ELASTICSEARCH_URL']
  Elasticsearch::Model.client = Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'])
end
