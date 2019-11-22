require 'rails_helper'

RSpec.describe UserPolicy do
  let(:user) { create(:user) }

  permissions :update? do
    it 'denies access if user is wrong' do
      expect(UserPolicy).not_to permit(create(:user), user)
    end

    it 'grants access if user is correct' do
      expect(UserPolicy).to permit(user, user)
    end
  end

  permissions :destroy? do
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
