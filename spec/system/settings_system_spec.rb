require 'rails_helper'

RSpec.describe 'Settings:', type: :system do
  include Auth0UserHelper

  specify 'A logged-in user can edit their profile' do
    # Given
    member = create(:member, name: 'ベス', url: nil, bio: nil, avatar: nil)
    user = create(:user, member: member)
    allow(auth0_client_double).to receive(:patch_user).with(user.auth0_id, anything)
    log_in_as user

    # When
    visit root_path
    click_on '設定'

    # Then
    expect(page).to have_title 'プロフィール設定'

    # When
    attach_file 'プロフィール画像', Rails.root.join('spec/fixtures/files/avatar.png')
    fill_in '名前', with: 'ギータ'
    fill_in 'URL', with: 'https://example.com/profile'
    fill_in '自己紹介', with: 'ギターに転向しました'
    click_button '更新する'

    # Then
    expect(page).to have_content 'プロフィールを更新しました'
    expect(page).to have_title 'ギータ'
    expect(page).to have_link href: 'https://example.com/profile'
    expect(page).to have_content 'ギターに転向しました'
  end

  specify 'A logged-in user can edit their email and notification settings' do
    # Given
    user = create(:user)
    stub_auth0_user(user, email_accepting: true)
    allow(auth0_client_double).to receive(:patch_user)
    log_in_as user

    # When
    visit root_path
    click_on '設定'
    click_on 'メール・通知'

    # Then
    expect(page).to have_title 'メール・通知設定'
    expect(page).to have_field('メールアドレス', with: user.email)
    expect(page).to have_checked_field('LiveLog からのお知らせメールを受け取る')

    # When
    uncheck 'LiveLog からのお知らせメールを受け取る'
    click_button '更新する'

    # Then
    expect(page).to have_content '更新しました'
    expect(auth0_client_double).to have_received(:patch_user).with(user.auth0_id, user_metadata: { livelog_email_notifications: false }).once
  end
end
