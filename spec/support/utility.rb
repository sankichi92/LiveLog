include ApplicationHelper

def t(key, options = {})
  I18n.translate(key, options)
end

def log_in_as(user, capybara: true, remember_me: '0')
  if capybara
    visit login_path
    fill_in 'session_email', with: user.email
    fill_in 'session_password', with: user.password
    check 'session_remember_me' if remember_me == '1'
    within('form') do
      click_button t('views.sessions.log_in')
    end
  else
    post login_path, params: { session: { email: user.email, password: user.password, remember_me: remember_me } }
  end
end

def authorized_headers(token, headers = {})
  { Authorization: "Token token=\"#{token.token}\", id=\"#{token.user.id}\"" }.merge(headers)
end
