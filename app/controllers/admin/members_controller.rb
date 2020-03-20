module Admin
  class MembersController < AdminController
    def index(year = Member.maximum(:joined_year))
      @year = year.to_i
      @members = Member.includes(:user).where(joined_year: @year).order(plays_count: :desc, id: :asc)
    end

    def new
      @member = Member.new(joined_year: Time.zone.now.nendo)
      @member.build_user
    end

    def create(member, user)
      @member = Member.new(member.permit(:joined_year, :name))

      if @member.save
        AdminActivityNotifyJob.perform_later(
          user: current_user,
          operation: '作成しました',
          object: @member,
          detail: @member.as_json,
          url: admin_members_url(year: @member.joined_year),
        )

        user = @member.build_user(user.permit(:email))
        if user.save(context: :invite)
          user.invite!
          flash[:notice] = "#{@member.joined_year_and_name} を追加・招待しました"
        else
          flash[:notice] = "#{@member.joined_year_and_name} を追加しました"
        end

        redirect_to admin_members_path(year: @member.joined_year)
      else
        @member.build_user(user.permit(:email))
        render :new, status: :unprocessable_entity
      end
    end

    def destroy(id)
      member = Member.find(id)
      member.destroy!
      AdminActivityNotifyJob.perform_now(
        user: current_user,
        operation: '削除しました',
        object: member,
        detail: member.as_json,
      )
      redirect_to admin_members_path(year: member.joined_year), notice: "#{member.joined_year_and_name} を削除しました"
    end
  end
end
