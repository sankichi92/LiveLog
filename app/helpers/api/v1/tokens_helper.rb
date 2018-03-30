module Api::V1::TokensHelper
  def authenticated?
    !@current_user.nil?
  end

  def current_user
    @current_user
  end
end
