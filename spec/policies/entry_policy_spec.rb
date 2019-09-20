require 'rails_helper'

RSpec.describe EntryPolicy do
  permissions :index?, :create? do
    it 'denies access if user is not logged in' do
      expect(described_class).not_to permit(nil, :entry)
    end

    it 'grants access if user is logged in' do
      expect(described_class).to permit(create(:user), :entry)
    end
  end
end
