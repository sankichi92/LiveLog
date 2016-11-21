require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do

  let(:user) { create(:user) }
  before { remember(user) }

  describe 'when session is nil' do
    it { expect(user).to eq current_user }
  end

  describe 'when remember digest is wrong' do
    before { user.update_attribute(:remember_digest, User.digest(User.new_token)) }
    it { expect(current_user).to be_nil }
  end
end
