require 'rails_helper'

RSpec.describe Member, type: :model do
  describe '#hide_ads?' do
    subject(:hide_ads?) { member.hide_ads? }

    let(:member) { create(:member, joined_year: joined_year) }

    context 'when member is not graduate' do
      let(:joined_year) { Time.zone.today.nendo - 3 }

      it { is_expected.to be_truthy }
    end

    context 'when member is graduate and has never donated' do
      let(:joined_year) { Time.zone.today.nendo - 4 }

      it { is_expected.to be_falsey }
    end

    context 'when member is graduate and has an active donation' do
      let(:joined_year) { Time.zone.today.nendo - 4 }

      before do
        create(:donation, member: member)
      end

      it { is_expected.to be_truthy }
    end

    context 'when member is graduate and has an expired donation' do
      let(:joined_year) { Time.zone.today.nendo - 4 }

      before do
        create(:donation, :expired, member: member)
      end

      it { is_expected.to be_falsey }
    end
  end
end
