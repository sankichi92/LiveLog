class AccountActivationsController < ApplicationController
  before_action :set_user
  before_action :check_inactivated, except: :destroy
  before_action :valid_user, only: %i[edit update]

  after_action :verify_authorized, except: %i[edit update]

  def new
    authorize @user, :invite?
  end

  def create(user)
    authorize @user, :invite?
    if @user.send_invitation(user[:email], current_user)
      flash[:success] = '招待メールを送信しました'
      redirect_to @user.member
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit; end

  def update(user)
    if user[:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit', status: :unprocessable_entity
    elsif @user.activate(user.permit(:password, :password_confirmation))
      Member.find(@user.id).update!(user_id: @user.id) # TODO
      log_in @user
      flash[:success] = 'LiveLog へようこそ！'
      redirect_to @user.member
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user, :change_status?
    @user.deactivate
    flash[:success] = 'アカウントを無効にしました'
    redirect_to @user.member
  end

  private

  def set_user(user_id)
    @user = User.find(user_id)
  end

  def check_inactivated
    return unless @user.activated?
    flash[:info] = 'アカウントはすでに有効化されています'
    redirect_to @user
  end

  def valid_user(t = nil)
    return if @user.authenticated?(:activation, t)
    flash[:danger] = '無効な URL です'
    redirect_to root_url
  end
end
