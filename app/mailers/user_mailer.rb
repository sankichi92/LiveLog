class UserMailer < ApplicationMailer

  def account_activation(user, inviter)
    @user = user
    @inviter = inviter
    mail to: user.email, subject: '【LiveLog】アカウントの有効化'
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: '【LiveLog】パスワード再設定'
  end
end
