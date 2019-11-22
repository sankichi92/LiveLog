require 'rails_helper'

RSpec.describe UserPolicy do
  let(:user) { create(:user) }

  permissions '.scope' do
    let!(:restricted_user) { create(:user, public: false) }
    let!(:public_user) { create(:user, public: true) }

    it 'returns all if user is logged in' do
      scope = described_class::Scope.new(create(:user), User)
      expect(scope.resolve).to include(restricted_user, public_user)
    end

    it 'returns public users if user is not logged in' do
      scope = described_class::Scope.new(nil, User)
      expect(scope.resolve).to include(public_user)
      expect(scope.resolve).not_to include(restricted_user)
    end
  end

  permissions :show? do
    it 'denies access if user is not logged in and record is not public' do
      user.update!(public: false)
      expect(UserPolicy).not_to permit(nil, user)
    end

    it 'grants access if record is public' do
      user.update!(public: true)
      expect(UserPolicy).to permit(nil, user)
    end

    it 'grants access if user is logged in' do
      expect(UserPolicy).to permit(create(:user), user)
    end
  end

  permissions :update? do
    it 'denies access if user is wrong' do
      expect(UserPolicy).not_to permit(create(:user), user)
    end

    it 'grants access if user is correct' do
      expect(UserPolicy).to permit(user, user)
    end
  end

  permissions :create?, :destroy? do
    it 'denies access if user is not logged in' do
      expect(UserPolicy).not_to permit(nil, user)
    end

    it 'denies access if user is logged in but not admin' do
      expect(UserPolicy).not_to permit(create(:user), user)
    end

    it 'grants access if user is admin' do
      expect(UserPolicy).to permit(create(:admin), user)
    end

    it 'grants access if user is elder' do
      expect(UserPolicy).to permit(create(:user, :elder), user)
    end
  end

  permissions :change_status? do
    it 'denies access if user is not logged in' do
      expect(UserPolicy).not_to permit(nil, user)
    end

    it 'denies access if user is logged in but not admin' do
      expect(UserPolicy).not_to permit(create(:user), user)
    end

    it 'grants access if user is admin' do
      expect(UserPolicy).to permit(create(:admin), user)
    end
  end
end
