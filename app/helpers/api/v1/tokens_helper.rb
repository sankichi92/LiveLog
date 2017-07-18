module Api::V1::TokensHelper

  def authenticated?
    !@current_user.nil?
  end
end
