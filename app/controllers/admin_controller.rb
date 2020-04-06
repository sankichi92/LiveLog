class AdminController < ActionController::Base # rubocop:disable Rails/ApplicationController
  include Session
  include RavenContext

  layout 'admin'

  before_action :require_current_user
  before_action :require_admin_user

  private

  def require_admin_user
    redirect_to root_path, alert: '権限がありません' if current_user.admin.nil?
  end
end
