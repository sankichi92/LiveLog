class UserMailer < ApplicationMailer
  default reply_to: 'sankichi92@ku-unplugged.net'

  def account_activation(user, inviter)
    @user = user
    @inviter = inviter
    subject = "#{inviter.name} さんが LiveLog に招待しています"
    mail to: user.email, subject: subject
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: 'パスワード再設定のご案内'
  end
end
