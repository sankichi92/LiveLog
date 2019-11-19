module LoginSystemHelper
  def log_in_as(user, remember_me: false)
    visit login_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    check '保存する' if remember_me
    click_button 'ログインする'
  end
end
