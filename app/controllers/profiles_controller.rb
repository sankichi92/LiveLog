class ProfilesController < ApplicationController
  before_action :require_current_user

  permits :name, :url, :bio, model_name: 'Member'

  def show
    @member = current_user.member
  end

  def update(member, avatar = nil)
    @member = current_user.member
    @member.assign_attributes(member.except(:avatar))

    if @member.valid?
      current_user.update_auth0_user!(name: @member.name) if @member.attribute_changed?(:name)
      @member.save!

      if avatar.present?
        @member.build_avatar if @member.avatar.nil?
        @member.avatar.upload_and_save!(avatar)
      end

      redirect_to @member, notice: 'プロフィールを更新しました'
    else
      render :show, status: :unprocessable_entity
    end
  end
end
