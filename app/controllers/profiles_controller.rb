class ProfilesController < ApplicationController
  before_action :require_current_user

  permits :name, :url, :bio, model_name: 'Member'

  def show
    @member = current_user.member
  end

  def update(member, avatar = nil)
    @member = current_user.member
    @member.assign_attributes(member)

    if @member.valid?
      if avatar.present?
        @member.build_avatar if @member.avatar.nil?
        @member.avatar.upload_and_save!(avatar)
      end

      if avatar.present? || @member.attribute_changed?(:name)
        current_user.update_auth0_user!(
          {
            name: @member.name,
            picture: @member.avatar&.image_url(192),
          }.compact,
        )
      end

      @member.save!

      redirect_to @member, notice: 'プロフィールを更新しました'
    else
      render :show, status: :unprocessable_entity
    end
  end
end
