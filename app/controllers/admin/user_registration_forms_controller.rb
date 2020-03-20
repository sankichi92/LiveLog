module Admin
  class UserRegistrationFormsController < AdminController
    permits :active_days

    def index
      @user_registration_forms = UserRegistrationForm.includes(admin: :member).all.reverse_order
    end

    def new
      @user_registration_form = current_user.user_registration_forms.new
    end

    def create(user_registration_form)
      @user_registration_form = current_user.user_registration_forms.new(user_registration_form)

      if @user_registration_form.save
        redirect_to admin_user_registration_forms_path, notice: "ID: #{@user_registration_form.id} を作成しました"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy(id)
      user_registration_form = UserRegistrationForm.find(id)
      user_registration_form.destroy!
      redirect_to admin_user_registration_forms_path, notice: "ID: #{user_registration_form.id} を削除しました"
    end
  end
end
