class PasswordResetsController < ApplicationController
  permits :password, :password_confirmation, model_name: 'User'

  before_action :set_user, only: %i[edit update]
  before_action :valid_user, only: %i[edit update]
  before_action :check_expiration, only: %i[edit update]

  def new; end

  def create(password_reset)
    @user = User.find_by(email: password_reset[:email])
    if @user
      @user.send_password_reset
      flash[:success] = 'パスワード再設定のためのメールを送信しました'
      redirect_to root_url
    else
      flash.now[:danger] = 'メールアドレスが見つかりませんでした'
      render 'new', status: :unprocessable_entity
    end
  end

  def edit; end

  def update(user)
    if user[:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit', status: :unprocessable_entity
    elsif @user.reset_password(user)
      log_in @user
      flash[:success] = 'パスワードが再設定されました'
      redirect_to @user.member
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  def set_user(email = nil)
    if email.blank?
      flash[:danger] = '無効な URL です'
      redirect_to root_url
    else
      @user = User.find_by(email: email)
    end
  end

  def valid_user(id)
    redirect_to root_url unless @user.authenticated?(:reset, id)
  end

  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = 'パスワード再設定の有効期限が過ぎてきます'
    redirect_to new_password_reset_url
  end
end
