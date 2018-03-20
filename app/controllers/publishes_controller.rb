class PublishesController < ApplicationController
  before_action :admin_user
  before_action :set_live
  before_action :draft_live

  def create
    @live.publish
    TweetJob.perform_now("#{@live.title} のセットリストが公開されました！\n#{live_url(@live)}")
    flash[:success] = '公開しました'
    redirect_to @live
  end

  private

  # Before filters

  def set_live
    @live = Live.find(params[:live_id])
  end

  def draft_live
    redirect_to root_url if @live.published?
  end
end
