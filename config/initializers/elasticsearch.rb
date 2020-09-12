# frozen_string_literal: true

if ENV['SEARCHBOX_SSL_URL']
  Elasticsearch::Model.client = Elasticsearch::Client.new(
    url: ENV['SEARCHBOX_SSL_URL'],
    http: { port: 443 }, # https://github.com/elastic/elasticsearch-ruby/issues/686
  )
end
