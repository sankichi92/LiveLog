class EntriesController < ApplicationController
  before_action :require_current_user

  def index
    @entries = Entry.joins(song: { plays: :member }).merge(Member.where(id: current_user.member_id))
  end
end
