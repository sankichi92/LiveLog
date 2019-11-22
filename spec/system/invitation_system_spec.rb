require 'rails_helper'

RSpec.describe 'Invitation System:', type: :system do
  specify 'A logged-in user can invite a member' do
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
end
