require 'rails_helper'

RSpec.describe 'Member Pages:', type: :system do
  specify "A user cannot see members' full names, but after logged-in, they can" do
    # Given
    user = create(:user)
    member = create(:member, last_name: '田中', first_name: '太郎', nickname: 'タロ')

    # When
    visit member_path(member)

    # Then
    expect(page).not_to have_content('田中')
    expect(page).not_to have_content('太郎')

    # When
    log_in_as user
    visit member_path(member)

    # Then
    expect(page).to have_content('田中')
    expect(page).to have_content('太郎')
  end
end
