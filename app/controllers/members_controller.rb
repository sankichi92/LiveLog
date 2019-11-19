class MembersController < ApplicationController
  def index
    @year = Member.joined_years.first
    @members = Member.with_attached_avatar.where(joined_year: @year).order(playings_count: :desc)
  end

  def year(year)
    @year = year.to_i
    @members = Member.with_attached_avatar.where(joined_year: year).order(playings_count: :desc)
    raise ActionController::RoutingError, "No members on #{@year}" if @members.empty?
    render :index
  end

  def show(id)
    @member = Member.find(id)
    @collaborators = Member.with_attached_avatar.collaborated_with(@member).with_played_count.to_a
    @songs = @member.published_songs.includes(:live, { playings: :member }, { 'audio_attachment': :blob }).newest_live_order
  end
end
