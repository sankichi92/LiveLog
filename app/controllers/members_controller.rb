class MembersController < ApplicationController
  def index(year = Member.maximum(:joined_year))
    @year = year.to_i
    @members = Member.with_attached_avatar.where(joined_year: @year).order(plays_count: :desc)
    raise ActionController::RoutingError, "No members on #{@year}" if @members.empty?
  end

  def show(id)
    @member = Member.find(id)
    @collaborators = Member.with_attached_avatar.collaborated_with(@member).with_played_count.to_a
    @songs = @member.published_songs.includes(:live, plays: :member).newest_live_order
  end

  def create(user_registration_form_token, member, user)
    @user_registration_form = UserRegistrationForm.find_by!(token: user_registration_form_token)
    return redirect_to root_path, alert: 'ユーザー登録フォームの有効期限が切れています' if @user_registration_form.expired?

    @member = Member.new(member.permit(:joined_year, :name))
    @member.build_user(user.permit(:email))

    if @member.user.valid?(:invite) && @member.save
      @member.user.invite!
      redirect_to root_path, notice: 'メールを送信しました。メールに記載されているURLにアクセスし、パスワードを設定してください'
    else
      render 'user_registration_forms/show', status: :unprocessable_entity
    end
  end
end
