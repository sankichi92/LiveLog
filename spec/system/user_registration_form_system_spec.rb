require 'rails_helper'

RSpec.describe 'User registration form:', type: :system do
  specify 'A user can register themselves' do
    # Given
    email = 'guitar@example.com'
    auth0_client = double(:app_auth0_client).tap do |auth0_client|
      allow(auth0_client).to receive(:user).and_raise(Auth0::NotFound.new('The user does not exist.'))
      allow(auth0_client).to receive(:create_user).and_return('user_id' => 'auth0|0', 'email' => email)
      allow(auth0_client).to receive(:change_password)
    end
    allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)
    user_registration_form = create(:user_registration_form)

    # When
    visit user_registration_form_path(user_registration_form.token)

    # Then
    expect(page).to have_title 'ユーザー登録'

    # When
    fill_in '入部年度', with: Time.zone.now.year
    fill_in '名前', with: 'ギータ'
    fill_in 'メールアドレス', with: email
    click_button '登録する'

    # Then
    expect(page).to have_content 'メールを送信しました。メールに記載されているURLにアクセスし、パスワードを設定してください'
  end
end
