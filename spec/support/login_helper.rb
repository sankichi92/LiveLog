module LoginHelper
  def log_in_as(user, capybara: true, remember_me: '0')
    if capybara
      visit login_path
      fill_in 'session_email', with: user.email
      fill_in 'session_password', with: user.password
      check 'session_remember_me' if remember_me == '1'
      within('form') do
        click_button 'ログインする'
      end
    else
      post login_path, params: { session: { email: user.email, password: user.password, remember_me: remember_me } }
    end
  end
end
