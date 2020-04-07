module Admin
  class UsersController < AdminController
    before_action -> { require_scope('write:members') }

    def destroy(member_id)
      user = User.find_by!(member_id: member_id)
      return redirect_to admin_members_path(year: user.member.joined_year), alert: '管理者のログイン情報は削除できません' if user.admin

      user.destroy_with_auth0_user!
      AdminActivityNotifyJob.perform_later(
        user: current_user,
        operation: 'ログイン情報を削除しました',
        object: user.member,
        url: admin_members_url(year: user.member.joined_year),
      )
      redirect_to admin_members_path(year: user.member.joined_year), notice: "#{user.member.joined_year_and_name} のログイン情報を削除しました"
    end
  end
end
