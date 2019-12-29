require 'app_auth0_client'

module Admin
  class MembersController < AdminController
    def index(year = Member.maximum(:joined_year))
      @year = year.to_i
      @members = Member.includes(:user).where(joined_year: @year).order(playings_count: :desc)
    end

    def new
      @member = Member.new(joined_year: Time.zone.now.year)
      @user = @member.build_user
    end

    def create(member, user)
      @member = Member.new(member.permit(:joined_year, :name))

      if @member.save
        AdminActivityNotifyJob.perform_later(current_user, "#{Member.model_name.human} #{@member.joined_year_and_name} を追加しました")

        @user = @member.build_user(user.permit(:email))
        if @user.valid?
          begin
            @user.create_with_auth0_user!
            AppAuth0Client.instance.change_password(@user.email, nil)
          rescue Auth0::BadRequest => e
            Raven.capture_exception(e, level: :debug)
            return redirect_to admin_members_path(year: @member.joined_year), alert: '招待メールの送信に失敗しました'
          end
        end

        redirect_to admin_members_path(year: @member.joined_year), notice: "#{@member.joined_year_and_name} を追加しました"
      else
        @user = @member.build_user(user.permit(:email))
        render :new, status: :unprocessable_entity
      end
    end

    def destroy(id)
      member = Member.find(id)
      member.destroy!
      AdminActivityNotifyJob.perform_later(current_user, "#{Member.model_name.human} #{member.joined_year_and_name} を削除しました")
      redirect_to admin_members_path(year: member.joined_year), notice: "#{member.joined_year_and_name} を削除しました"
    end
  end
end
