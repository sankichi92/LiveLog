module LoginRequestHelper
  def log_in_as(user, remember_me: false)
    post login_path, params: {
      session: {
        email: user.email,
        password: user.password,
        remember_me: remember_me ? '1' : '0',
      },
    }
  end
end
