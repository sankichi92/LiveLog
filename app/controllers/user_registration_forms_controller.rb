# frozen_string_literal: true

class UserRegistrationFormsController < ApplicationController
  def show(token)
    @user_registration_form = UserRegistrationForm.find_by!(token: token)
    return redirect_to root_path, alert: 'ユーザー登録フォームの有効期限が切れています' if @user_registration_form.expired?

    @member = Member.new(joined_year: Time.zone.now.nendo)
    @member.build_user
  end
end
