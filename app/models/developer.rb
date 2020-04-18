class Developer < ApplicationRecord
  belongs_to :user
  has_many :clients, dependent: :restrict_with_exception

  def avatar_url
    userinfo.fetch(:avatar_url)
  end

  def userinfo
    @userinfo ||= github_client.user.to_h.tap do |info|
      update!(github_username: info[:login]) if info[:login].present? && info[:login] != github_username
    end
  end

  private

  def github_client
    @github_client ||= Octokit::Client.new(access_token: github_access_token)
  end
end
