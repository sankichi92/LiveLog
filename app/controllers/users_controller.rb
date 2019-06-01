require 'csv'

class UsersController < ApplicationController
  permits :first_name, :last_name, :furigana, :joined, :nickname, :email, :url, :intro, :public, :subscribing, :avatar

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index(y = User.joined_years.first)
    @year = y.to_i
    raise ActionController::RoutingError, 'Not Found' unless User.joined_years.include?(@year)
    @users = policy_scope(User).with_attached_avatar.where(joined: y).order(playings_count: :desc, furigana: :asc)
  end

  def show(id)
    @user = User.includes(:playings).find(id)
    authorize @user
    @songs = @user.songs.with_attached_audio.includes(playings: :user).published.order_by_live
  end

  def new
    @user = User.new
    authorize @user
  end

  def create(user)
    @user = User.new(user)
    authorize @user
    if @user.save
      flash[:success] = t('flash.messages.created', name: @user.name)
      redirect_to new_user_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def csv(csv)
    @user = User.new
    authorize @user, :create?

    attrs = %w[joined last_name first_name furigana]
    CSV.new(csv.to_io.set_encoding('UTF-8'), headers: attrs).each do |row|
      user = User.new(row.to_h.slice(*attrs))
      unless user.save
        @user.errors.add(:base, %("#{row}" の登録に失敗しました))
      end
    end

    if @user.errors.empty?
      flash[:success] = '登録しました'
      redirect_to users_path
    else
      render status: :unprocessable_entity
    end
  end

  def edit(id)
    @user = User.find(id)
    authorize @user
  end

  def update(id, user)
    @user = User.find(id)
    authorize @user
    if @user.update(user)
      flash[:success] = t('flash.controllers.users.updated')
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy(id)
    @user = User.find(id)
    authorize @user
    @user.destroy
  rescue ActiveRecord::DeleteRestrictionError => e
    flash[:danger] = e.message
    redirect_to @user
  else
    flash[:success] = t('flash.messages.deleted', name: @user.name)
    redirect_to users_url
  end

  private

  def search_params
    params.permit(:artist, :instruments, :players_lower, :players_upper, :date_lower, :date_upper, :user_id)
  end
end
