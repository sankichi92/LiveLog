# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User registration form:' do
  specify 'A user can register themselves' do
    # Given
    stub_request(:post, 'https://slack.com/api/chat.postMessage')
    email = 'guitar@example.com'
    auth0_client = double(:app_auth0_client).tap do |double|
      allow(double).to receive(:user).and_raise(Auth0::NotFound.new('The user does not exist.'))
      allow(double).to receive(:create_user).and_return('user_id' => 'auth0|0', 'email' => email)
      allow(double).to receive(:change_password)
    end
    allow(LiveLog::Auth0Client).to receive(:instance).and_return(auth0_client)
    user_registration_form = create(:user_registration_form)

    # When
    visit user_registration_form_path(user_registration_form.token)

    # Then
    expect(page).to have_title 'ユーザー登録'

    # When
    joined_year = Time.zone.now.year
    name = 'ギータ'
    fill_in '入部年度', with: joined_year
    fill_in '名前', with: name
    fill_in 'メールアドレス', with: email
    click_button '登録する'

    # Then
    expect(page).to have_title "#{joined_year} #{name}"
    expect(page).to have_content 'メールを送信しました。メールに記載されているURLにアクセスし、パスワードを設定してください'
  end
end
