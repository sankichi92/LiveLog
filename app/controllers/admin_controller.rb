# frozen_string_literal: true

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

  def require_scope(scope)
    redirect_back fallback_location: admin_root_path, alert: "#{t(scope, scope: 'admin_scope')}権限がありません" unless current_user.admin.scopes.include?(scope)
  end
end
