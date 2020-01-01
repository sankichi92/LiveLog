require 'rails_helper'

RSpec.describe SongPolicy do
  let(:song) { create(:song) }

  permissions :play? do
    context 'when song is open' do
      let(:song) { create(:song, status: :open) }

      it 'grants access even if user is not logged in' do
        expect(SongPolicy).to permit(nil, song)
      end
    end

    context 'when song is closed' do
      let(:song) { create(:song, status: :closed) }

      it 'denies access if user is not logged in' do
        expect(SongPolicy).not_to permit(nil, song)
      end

      it 'grants access if user is logged in' do
        expect(SongPolicy).to permit(create(:user), song)
      end
    end

    context 'when song is secret' do
      let(:song) { create(:song, status: :secret) }

      it 'denies access if user is not logged in' do
        expect(SongPolicy).not_to permit(nil, song)
      end

      it 'denies access if user is logged in but not player' do
        expect(SongPolicy).not_to permit(create(:user), song)
      end

      it 'grants access if user is player' do
        user = create(:user)
        create(:playing, member: user.member, song: song)
        expect(SongPolicy).to permit(user, song)
      end
    end
  end

  permissions :update? do
    it 'denies access if user is not logged in' do
      expect(SongPolicy).not_to permit(nil, song)
    end

    it 'denies access if user is logged in but not admin or player' do
      expect(SongPolicy).not_to permit(create(:user), song)
    end

    it 'grants access if user is player' do
      user = create(:user)
      create(:playing, member: user.member, song: song)
      expect(SongPolicy).to permit(user, song)
    end

    it 'grants access if user is admin' do
      expect(SongPolicy).to permit(create(:admin), song)
    end
  end
end
