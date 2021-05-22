# frozen_string_literal: true

class GithubTokenReset < ApplicationBatch
  def run
    Developer.all.find_each do |developer|
      logger.info "Processing #{developer.github_username}"

      client = Octokit::Client.new(client_id: ENV.fetch('GITHUB_CLIENT_ID'), client_secret: ENV.fetch('GITHUB_CLIENT_SECRET'))
      response = client.reset_token(developer.github_access_token)
      developer.update!(github_access_token: response.token)
    end
  end
end
