class UsersController < ApplicationController
  permits :first_name, :last_name, :furigana, :joined, :nickname, :email, :url, :intro, :public, :subscribing

  after_action :verify_authorized, except: :index

  def index(active = 'true')
    @users = if active != 'false'
               User.active.natural_order
             else
               User.natural_order
             end
  end

  def show(id)
    @user = User.includes(songs: :live).find(id)
    authorize @user
    @songs = @user.songs.published.order_by_live.includes(playings: :user)
  end

  def search(id)
    @user = User.includes(songs: :live).find(id)
    authorize @user, :show?
    query = Song::SearchQuery.new(search_params.merge(ids: @user.songs.pluck(:id), logged_in: logged_in?))
    return render :show, status: :unprocessable_entity if query.invalid?
    @songs = Song.search(query).records(includes: { playings: :user })
    render :show
  end

  def new
    @user = User.new
    authorize @user
  end

  def create(user)
    @user = User.new(user)
    authorize @user
    if @user.save
      flash[:success] = t(:created, name: @user.name)
      redirect_to new_user_url
    else
      render :new, status: :unprocessable_entity
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
      flash[:success] = t(:updated, name: t(:profile))
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
    flash.now[:danger] = e.message
    render :show, status: :unprocessable_entity
  else
    flash[:success] = t(:deleted, name: @user.name)
    redirect_to users_url
  end

  private

  def search_params
    params.permit(:artist, :instruments, :players_lower, :players_upper, :date_lower, :date_upper, :user_id)
  end
end
