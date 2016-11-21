include ApplicationHelper

def log_in_as(user, capybara: true, remember_me: false)
  if capybara
    visit login_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    check 'Remember me' if remember_me
    click_button 'Log in'
  else
    session[:user_id] = user.id
  end
end

