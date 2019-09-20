require 'rails_helper'

RSpec.describe LivePolicy do
  let(:live) { create(:live) }

  permissions :album? do
    it 'denies access if user is not logged in' do
      expect(described_class).not_to permit(nil, live)
    end

    it 'grants access if user is logged in' do
      expect(described_class).to permit(create(:user), live)
    end
  end

  permissions :publish? do
    it 'denies access if user is not logged in' do
      expect(described_class).not_to permit(nil, live)
    end

    it 'denies access if user is logged in but not admin' do
      expect(described_class).not_to permit(create(:user), live)
    end

    it 'grants access if user is admin' do
      expect(described_class).to permit(create(:admin), live)
    end
  end

  permissions :create?, :update?, :destroy? do
    it 'denies access if user is not logged in' do
      expect(described_class).not_to permit(nil, live)
    end

    it 'denies access if user is logged in but not admin' do
      expect(described_class).not_to permit(create(:user), live)
    end

    it 'grants access if user is admin' do
      expect(described_class).to permit(create(:admin), live)
    end

    it 'grants access if user is elder' do
      expect(described_class).to permit(create(:user, :elder), live)
    end
  end
end
