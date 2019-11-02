require 'rails_helper'

RSpec.describe EntryPolicy do
  permissions :index?, :create? do
    it 'denies access if user is not logged in' do
      expect(EntryPolicy).not_to permit(nil, :entry)
    end

    it 'grants access if user is logged in' do
      expect(EntryPolicy).to permit(create(:user), :entry)
    end
  end
end
