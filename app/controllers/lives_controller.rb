# frozen_string_literal: true

class LivesController < ApplicationController
  before_action :require_current_user, only: :album

  def index
    @lives = Live.published.newest_order
  end

  def show(id)
    @live = Live.includes(songs: { plays: :member }).published.find(id)
  end

  def album(id)
    @live = Live.find(id)

    if @live.album_url.present?
      redirect_to @live.album_url, allow_other_host: true
    else
      raise ActionController::RoutingError, "Live id #{id} does not have album_url"
    end
  end
end
