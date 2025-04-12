# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Entry system:' do
  specify 'A logged-in user creates an entry', :js do
    # Given
    stub_request(:post, 'https://slack.com/api/chat.postMessage')
    date = 1.month.from_now.to_date
    create(:live, :unpublished, :with_entry_guideline, date:)
    member = create(:member)
    user = create(:user)
    log_in_as user

    # When
    visit entries_path

    # Then
    expect(page).to have_title '新規エントリー'

    # When
    click_on '演者を追加する'
    click_on '演奏可能時間を追加する'

    # Then
    expect(page).to have_css '.play-form', count: 2
    expect(page).to have_css '.playable-time-form', count: 2

    # When
    fill_in '曲名', with: '恋はリズムに乗って'
    fill_in 'アーティスト', with: '□□□'
    within first('.play-form-visible-fields') do
      fill_in '楽器', with: 'Vo'
      select user.member.joined_year_and_name, from: 'メンバー'
    end
    within all('.play-form-visible-fields')[1] do
      fill_in '楽器', with: 'Gt'
      select member.joined_year_and_name, from: 'メンバー'
    end
    within first('.playable-time-form-visible-fields') do
      find('input[name*=lower]').set(date + 18.hours)
      find('input[name*=upper]').set(date + 20.hours)
    end
    within all('.playable-time-form-visible-fields')[1] do
      find('input[name*=lower]').set(date + 21.hours)
      find('input[name*=upper]').set(date + 22.hours)
    end
    click_on '登録する'

    # Then
    expect(page).to have_content '作成しました'
    expect(page).to have_content '恋はリズムに乗って / □□□'
    expect(page).to have_content "Vo.#{user.member.name}"
    expect(page).to have_content "Gt.#{member.name}"
    expect(page).to have_content "#{date.strftime('%-m/%-d')} 18:00〜#{date.strftime('%-m/%-d')} 20:00"
    expect(page).to have_content "#{date.strftime('%-m/%-d')} 21:00〜#{date.strftime('%-m/%-d')} 22:00"
  end

  specify 'A submitter edits their entry', :js do
    # Given
    stub_request(:post, 'https://slack.com/api/chat.postMessage')
    user = create(:user)
    entry = create(:entry, member: user.member, notes: '', playable_times_count: 2)
    log_in_as user

    # When
    visit edit_entry_path(entry)

    # Then
    expect(page).to have_title 'エントリーの編集'

    # When
    fill_in '備考', with: '間奏でボーカルがフルートを吹きます'
    within '.playable-time-form-visible-fields', match: :first do
      click_on '削除'
    end
    click_on '更新する'

    # Then
    expect(page).to have_content "エントリー ID: #{entry.id} を更新しました"
    expect(page).to have_content '間奏でボーカルがフルートを吹きます'
    expect(entry.reload.playable_times.count).to eq 1
  end

  specify 'A submitter deletes their entry' do
    # Given
    stub_request(:post, 'https://slack.com/api/chat.postMessage')
    user = create(:user)
    entry = create(:entry, member: user.member)
    log_in_as user

    # When
    visit edit_entry_path(entry)
    click_on '削除する'

    # Then
    expect(page).to have_content "エントリー ID: #{entry.id} を削除しました"
    expect { entry.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
