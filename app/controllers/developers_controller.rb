class DevelopersController < ApplicationController
  before_action :require_current_user

  def show
    @developer = current_user.developer

    unless @developer.nil?
      begin
        @developer.fetch_github_user!
      rescue Octokit::Unauthorized
        @developer = nil if @developer.destroyed?
      end
    end
  end
end
