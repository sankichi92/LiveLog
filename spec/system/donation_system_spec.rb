# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Donation system:', type: :system do
  include ActiveSupport::Testing::TimeHelpers

  specify 'A guest user and a non-graduate user does not see the donation alert and page' do
    # When
    visit root_path

    # Then
    expect(page).not_to have_content 'OB・OG の皆さまへ'
    expect(page).not_to have_content 'カンパのお願い'

    # When
    log_in_as create(:user)
    visit root_path

    # Then
    expect(page).not_to have_content 'OB・OG の皆さまへ'
    expect(page).not_to have_content 'カンパのお願い'
  end

  specify 'A graduate user sees the donation alert, and after donation, they do not see the alert, but after the donation expired, they see it again' do
    # Given
    user = create(:user, :graduate)
    log_in_as user

    # When
    visit root_path

    # Then
    expect(page).to have_content 'OB・OG の皆さまへ'
    expect(page).to have_content 'カンパのお願い'

    # When
    create(:donation, member: user.member, amount: 1000)
    visit root_path

    # Then
    expect(page).not_to have_content 'OB・OG の皆さまへ'

    # When
    travel 20.months + 1.day do
      visit root_path

      # Then
      expect(page).to have_content 'OB・OG の皆さまへ'
    end
  end
end
