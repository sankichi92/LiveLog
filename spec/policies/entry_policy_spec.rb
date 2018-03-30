require 'rails_helper'

RSpec.describe EntryPolicy do
  subject { described_class }

  permissions :index?, :create? do
    it 'denies access if user is not logged in' do
      expect(subject).not_to permit(nil, :entry)
    end

    it 'grants access if user is logged in' do
      expect(subject).to permit(create(:user), :entry)
    end
  end
end
