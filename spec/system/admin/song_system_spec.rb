require 'rails_helper'

RSpec.describe 'Admin song system:', type: :system do
  specify 'An admin creates a song', js: true do
    # Given
    live = create(:live)
    member1 = create(:member, name: '徳浦')
    member2 = create(:member, name: '三岡')
    admin = create(:admin)
    log_in_as admin

    # When
    visit admin_live_path(live)
    click_on '曲を追加する'

    # Then
    expect(page).to have_selector '.play-form', count: 1

    # When
    click_button '演者を追加する'
    click_button '演者を追加する'

    # Then
    expect(page).to have_selector '.play-form', count: 3

    # When
    click_button '削除', match: :first

    # Then
    expect(page).to have_selector '.play-form', count: 3
    expect(page).to have_selector '.play-form-visible-fields', count: 2

    # When
    fill_in '曲名', with: 'Lion'
    fill_in 'アーティスト名', with: 'DEPAPEPE'
    within all('.play-form-visible-fields')[0] do
      fill_in '楽器', with: 'Gt'
      select member1.joined_year_and_name, from: 'メンバー'
    end
    within all('.play-form-visible-fields')[1] do
      fill_in '楽器', with: 'Gt'
      select member2.joined_year_and_name, from: 'メンバー'
    end
    click_button '登録する'

    # Then
    expect(page).to have_content(/ID: \d+ を追加しました/)
    expect(page).to have_content 'Gt.徳浦'
    expect(page).to have_content 'Gt.三岡'
  end

  specify 'An admin edits a song', js: true do
    # Given
    members = create_list(:member, 3)
    song = create(:song, name: 'before', members: members)
    admin = create(:admin)
    log_in_as admin

    # When
    visit edit_admin_song_path(song)

    # Then
    expect(page).to have_selector '.play-form', count: 3

    # When
    fill_in '曲名', with: 'after'
    click_button '削除', match: :first
    click_button '更新する'

    # Then
    expect(page).to have_content "ID: #{song.id} を更新しました"
    expect(song.reload.name).to eq 'after'
    expect(song.plays.count).to eq 2
  end
end
