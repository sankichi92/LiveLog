require 'app_auth0_client'

module Admin
  class MembersController < AdminController
    permits :joined_year, :name

    def index(year = Member.maximum(:joined_year))
      @year = year.to_i
      @members = Member.includes(:user).where(joined_year: @year).order(playings_count: :desc)
    end

    def new
      @member = Member.new
    end

    def create(member, email = nil)
      @member = Member.new(member)

      if @member.save
        AdminActivityNotifyJob.perform_later(current_user, "メンバー #{@member.joined_year_and_name} を追加しました")

        if email.present?
          begin
            @member.create_user_with_auth0!(email)
            AppAuth0Client.instance.change_password(email, nil)
          rescue Auth0::BadRequest => e
            Raven.capture_exception(e, level: :debug)
            return redirect_to admin_members_path(year: @member.joined_year), alert: '招待メールの送信に失敗しました'
          end
        end

        redirect_to admin_members_path(year: @member.joined_year), notice: "#{@member.joined_year} #{@member.name} を追加しました"
      else
        render :new, status: :unprocessable_entity
      end
    end
  end
end
