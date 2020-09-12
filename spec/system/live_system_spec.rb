# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Live:', type: :system do
  specify 'A user can see the live index page and a live detail page, and after logged-in, they can see album', js: true do
    # Given
    live = create(:live, :with_songs, album_url: 'https://example.com/album')
    user = create(:user)

    # When
    visit lives_path

    # Then
    expect(page).to have_title 'ライブ'

    # When
    find('td', text: live.name).click

    # Then
    expect(page).to have_title live.title
    expect(page).not_to have_link 'アルバム'

    # When
    log_in_as user
    visit live_path(live)

    # Then
    expect(page).to have_title live.title
    expect(page).to have_link 'アルバム'
  end
end
