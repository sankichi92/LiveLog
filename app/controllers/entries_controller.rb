class EntriesController < ApplicationController
  permits :name, :artist, :original, :status, :preferred_rehearsal_time, :preferred_performance_time, :notes, playings_attributes: %i[id user_id inst _destroy], model_name: 'Song'

  before_action :set_live
  before_action :draft_live

  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Entry
    @songs = policy_scope(@live.songs).includes(playings: :user).order(:time, :order, created_at: :desc)
  end

  def new
    authorize Entry
    @song = @live.songs.build
    @song.playings.build
  end

  def create(song)
    authorize Entry
    @song = @live.songs.build(song)
    return render(status: :unprocessable_entity) unless @song.save
    entry = Entry.new(
      applicant: current_user,
      song: @song,
      preferred_rehearsal_time: song[:preferred_rehearsal_time],
      preferred_performance_time: song[:preferred_performance_time],
      notes: song[:notes]
    )
    entry.send_email
    flash[:success] = t(:entered, live: @live.title, song: @song.title)
    redirect_to live_entries_url(@live)
  rescue ActiveRecord::RecordNotUnique
    @song.errors.add(:playings, :duplicated)
    render status: :unprocessable_entity
  end

  private

  def set_live(live_id)
    @live = Live.find(live_id)
  end

  def draft_live
    redirect_to live_url(@live), status: :moved_permanently if @live.published?
  end
end
