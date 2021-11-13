# frozen_string_literal: true

if ENV['ELASTICSEARCH_URL']
  Elasticsearch::Model.client = Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'])
else
  docker_port = `docker-compose port elasticsearch 9200`.chomp.split(':').last
  Elasticsearch::Model.client = Elasticsearch::Client.new(url: "http://localhost:#{docker_port}") if docker_port.present?
end
