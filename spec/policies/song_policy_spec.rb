require 'rails_helper'

RSpec.describe SongPolicy do
  subject { described_class }

  let(:song) { create(:song) }

  permissions :play? do
    context 'when song is open' do
      let(:song) { create(:song, status: :open) }

      it 'grants access even if user is not logged in' do
        expect(subject).to permit(nil, song)
      end
    end

    context 'when song is closed' do
      let(:song) { create(:song, status: :closed) }

      it 'denies access if user is not logged in' do
        expect(subject).not_to permit(nil, song)
      end

      it 'grants access if user is logged in' do
        expect(subject).to permit(create(:user), song)
      end
    end

    context 'when song is secret' do
      let(:song) { create(:song, status: :secret) }

      it 'denies access if user is not logged in' do
        expect(subject).not_to permit(nil, song)
      end

      it 'denies access if user is logged in but not player' do
        expect(subject).not_to permit(create(:user), song)
      end

      it 'grants access if user is player' do
        expect(subject).to permit(create(:user, songs: [song]), song)
      end
    end
  end

  permissions :create?, :destroy? do
    it 'denies access if user is not logged in' do
      expect(subject).not_to permit(nil, song)
    end

    it 'denies access if user is logged in but not admin' do
      expect(subject).not_to permit(create(:user), song)
    end

    it 'grants access if user is an admin' do
      expect(subject).to permit(create(:admin), song)
    end

    it 'grants access if user is elder' do
      expect(subject).to permit(create(:user, :elder), song)
    end
  end

  permissions :update? do
    it 'denies access if user is not logged in' do
      expect(subject).not_to permit(nil, song)
    end

    it 'denies access if user is logged in but not admin or player' do
      expect(subject).not_to permit(create(:user), song)
    end

    it 'grants access if user is player' do
      expect(subject).to permit(create(:user, songs: [song]), song)
    end

    it 'grants access if user is admin' do
      expect(subject).to permit(create(:admin), song)
    end

    it 'grants access if user is elder' do
      expect(subject).to permit(create(:user, :elder), song)
    end
  end
end
