# frozen_string_literal: true

class SlackController < ApplicationController
  before_action :require_current_user

  def show
    redirect_to slack_invitation_url, allow_other_host: true
  end
end
