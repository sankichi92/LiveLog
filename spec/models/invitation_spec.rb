require 'rails_helper'

RSpec.describe Invitation, type: :model do
  describe 'before_create callback' do
    it 'destroys the previous invitation if it exists' do
      # Given
      member = create(:member)
      previous_invitation = create(:invitation, member: member)

      # When
      new_invitation = create(:invitation, member: member)

      # Then
      expect { previous_invitation.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(new_invitation).to be_persisted
    end
  end
end
