module Admin
  class AdministratorsController < AdminController
    before_action -> { require_scope('write:admins') }, only: %i[create edit update destroy]

    def index
      @admins = Administrator.eager_load(user: { member: :avatar }).order('members.joined_year': :desc, 'members.plays_count': :desc)
    end

    def create(member_id)
      user = User.find_by!(member_id: member_id)
      admin = user.create_admin!
      AdminActivityNotifyJob.perform_later(
        user: current_user,
        operation: '作成しました',
        object: admin,
        detail: admin.as_json,
        url: admin_administrators_url,
      )
      redirect_to admin_administrators_path, notice: "#{user.member.joined_year_and_name} を管理者にしました"
    end

    def edit(id)
      @admin = Administrator.find(id)
    end

    def update(id, administrator)
      @admin = Administrator.find(id)

      if @admin.update(scopes: Array(administrator[:scopes]).reject(&:blank?))
        AdminActivityNotifyJob.perform_later(
          user: current_user,
          operation: '更新しました',
          object: @admin,
          detail: @admin.previous_changes,
          url: admin_administrators_url,
        )
        redirect_to admin_administrators_path, notice: "#{@admin.user.member.joined_year_and_name} の管理者権限を更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy(id)
      admin = Administrator.find(id)
      admin.destroy!
      AdminActivityNotifyJob.perform_now(
        user: current_user,
        operation: '削除しました',
        object: admin,
        detail: admin.as_json,
        url: admin_administrators_url,
      )
      redirect_to admin_administrators_path, notice: "#{admin.user.member.joined_year_and_name} の管理者権限を剥奪しました"
    end
  end
end
