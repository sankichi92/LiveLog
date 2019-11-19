class ProfilesController < ApplicationController
  before_action :require_current_user

  permits :name, :url, :bio, :avatar, model_name: 'Member'

  def show
    @member = current_user.member
  end

  def update(member)
    @member = current_user.member
    if @member.update(member)
      flash[:success] = 'プロフィールを更新しました'
      redirect_to @member
    else
      render :show, status: :unprocessable_entity
    end
  end
end
