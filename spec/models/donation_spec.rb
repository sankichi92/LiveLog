require 'rails_helper'

RSpec.describe Donation, type: :model do
  describe '#active?' do
    subject(:active?) { donation.active?(on: date) }

    let(:donation) { create(:donation, amount: 1000) }

    context 'with date before or equal to expires_on' do
      let(:date) { donation.donated_on + 20.months }

      it { is_expected.to be true }
    end

    context 'with date after expires_on' do
      let(:date) { donation.donated_on + 20.months + 1.day }

      it { is_expected.to be false }
    end
  end
end
