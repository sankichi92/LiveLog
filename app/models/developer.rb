# frozen_string_literal: true

class Developer < ApplicationRecord
  belongs_to :user
  has_many :clients, dependent: :restrict_with_exception

  def fetch_github_user!
    github_client.user.to_h.tap do |user|
      update!(github_username: user[:login]) if user[:login].present? && user[:login] != github_username
    end
  rescue Octokit::Unauthorized => e
    Sentry.capture_exception(e, level: :debug)
    if clients.empty?
      destroy!
    else
      update!(github_access_token: nil)
    end
    raise e
  end

  private

  def github_client
    @github_client ||= Octokit::Client.new(access_token: github_access_token)
  end
end
