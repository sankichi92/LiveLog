require 'rails_helper'

RSpec.describe 'Invitation System:', type: :system do
  specify 'A logged-in user can invite a member' do
    Capybara.using_session("Inviter's session") do
      # Given
      user = create(:user)
      member = create(:member, name: 'ギータ')
      log_in_as user

      # When
      visit member_path(member)
      click_link 'LiveLog に招待する'

      # Then
      expect(page).to have_title 'ギータを招待する'

      # When
      fill_in 'メールアドレス', with: 'giita@example.com'
      click_on '送信する'

      # Then
      expect(page).to have_content '招待メールを送信しました'
    end

    # When
    mail = ActionMailer::Base.deliveries.last
    uri = URI.parse(mail.body.to_s.match(URI::DEFAULT_PARSER.make_regexp).to_s)
    visit uri.request_uri

    # Then
    expect(page).to have_title 'ユーザー登録'

    # When
    fill_in 'パスワード', with: 'password'
    fill_in 'パスワード確認用', with: 'password'
    click_button '登録する'

    # Then
    expect(page).to have_content 'LiveLog へようこそ！'
  end
end
