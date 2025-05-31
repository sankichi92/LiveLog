# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Live:' do
  specify 'A user can see a live detail page, and after logged-in, they can see album', :js do
    # Given
    live = create(:live, :with_songs, album_url: 'https://example.com/album')
    user = create(:user)

    # When
    visit live_path(live)

    # Then
    expect(page).to have_title live.title
    expect(page).to have_no_link 'アルバム'

    # When
    log_in_as user
    visit live_path(live)

    # Then
    expect(page).to have_title live.title
    expect(page).to have_link 'アルバム'
  end
end
