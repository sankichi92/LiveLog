module Admin
  class AdminsController < AdminController
    def create(member_id)
      user = User.find_by!(member_id: member_id)
      user.create_admin!
      AdminActivityNotifyJob.perform_later(
        user: current_user,
        operation: '管理者にしました',
        object: user.member,
        url: admin_members_url(year: user.member.joined_year),
      )
      redirect_to admin_members_path(year: user.member.joined_year), notice: "#{user.member.joined_year_and_name} を管理者にしました"
    end

    def destroy(member_id)
      user = User.find_by!(member_id: member_id)
      user.admin.destroy!
      AdminActivityNotifyJob.perform_later(
        user: current_user,
        operation: '管理者権限を剥奪しました',
        object: user.member,
        url: admin_members_url(year: user.member.joined_year),
      )
      redirect_to admin_members_path(year: user.member.joined_year), notice: "#{user.member.joined_year_and_name} の管理者権限を剥奪しました"
    end
  end
end
