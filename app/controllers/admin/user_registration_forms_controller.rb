module Admin
  class UserRegistrationFormsController < AdminController
    before_action -> { require_scope('write:user_registration_forms') }

    permits :active_days

    def index
      @user_registration_forms = UserRegistrationForm.includes(admin: { user: { member: :avatar } }).all.reverse_order
    end

    def new
      @user_registration_form = current_user.admin.user_registration_forms.new
    end

    def create(user_registration_form)
      @user_registration_form = current_user.admin.user_registration_forms.new(user_registration_form)

      if @user_registration_form.save
        AdminActivityNotifyJob.perform_later(
          user: current_user,
          operation: '作成しました',
          object: @user_registration_form,
          detail: @user_registration_form.as_json(except: :token),
          url: admin_user_registration_forms_url,
        )
        redirect_to admin_user_registration_forms_path, notice: "ID: #{@user_registration_form.id} を作成しました"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy(id)
      user_registration_form = UserRegistrationForm.find(id)
      user_registration_form.destroy!
      AdminActivityNotifyJob.perform_now(
        user: current_user,
        operation: '削除しました',
        object: user_registration_form,
        detail: user_registration_form.as_json,
      )
      redirect_to admin_user_registration_forms_path, notice: "ID: #{user_registration_form.id} を削除しました"
    end
  end
end
