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
      redirect_to root_url, notice: 'パスワード再設定のためのメールを送信しました'
    else
      flash.now.alert = 'メールアドレスが見つかりませんでした'
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
      redirect_to @user.member, notice: 'パスワードが再設定されました'
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  def set_user(email = nil)
    if email.blank?
      redirect_to root_url, alert: '無効な URL です'
    else
      @user = User.find_by(email: email)
    end
  end

  def valid_user(id)
    redirect_to root_url unless @user.authenticated?(:reset, id)
  end

  def check_expiration
    redirect_to new_password_reset_url, alert: 'パスワード再設定の有効期限が過ぎてきます' if @user.password_reset_expired?
  end
end
