class UserMailer < ApplicationMailer

  def account_activation
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  def password_reset
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
