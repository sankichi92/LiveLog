class PasswordsController < ApplicationController
  permits :password, :password_confirmation, model_name: 'User'

  before_action :set_user

  after_action :verify_authorized

  def edit
    authorize @user
  end

  def update(current_password, user)
    authorize @user
    if @user.authenticate(current_password)
      if @user.update(user)
        flash[:success] = t('flash.messages.updated', name: User.human_attribute_name(:password))
        redirect_to @user
      else
        render :edit, status: :unprocessable_entity
      end
    else
      @user.errors.add(:password, :wrong)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user(user_id)
    @user = User.find(user_id)
  end
end
