class Admin::AdminsController < AdminController
  def create(member_id)
    user = User.find_by!(member_id: member_id)
    user.update!(admin: true)
    AdminActivityNotifyJob.perform_later(current_user, "#{Member.model_name.human} #{user.member.joined_year_and_name} を管理者にしました")
    redirect_to admin_members_path(year: user.member.joined_year), notice: "#{user.member.joined_year_and_name} を管理者にしました"
  end

  def destroy(member_id)
    user = User.find_by!(member_id: member_id)
    user.update!(admin: false)
    AdminActivityNotifyJob.perform_later(current_user, "#{Member.model_name.human} #{user.member.joined_year_and_name} の管理者権限を剥奪しました")
    redirect_to admin_members_path(year: user.member.joined_year), notice: "#{user.member.joined_year_and_name} の管理者権限を剥奪しました"
  end
end
