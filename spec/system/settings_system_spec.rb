require 'rails_helper'

RSpec.describe 'Settings:', type: :system do
  specify 'A logged-in user can edits their profile' do
    # Given
    member = create(:member, name: 'ベス', url: nil, bio: nil, avatar: nil)
    user = create(:user, member: member)
    log_in_as user

    # When
    visit root_path
    click_on 'Settings'

    # Then
    expect(page).to have_title 'プロフィール設定'

    # When
    attach_file 'プロフィール画像', Rails.root.join('spec', 'fixtures', 'files', 'avatar.png')
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
end
