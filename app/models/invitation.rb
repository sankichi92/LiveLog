class Invitation < ApplicationRecord
  has_secure_token

  belongs_to :member
  belongs_to :inviter, class_name: 'User'

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_create :destroy_previous_invitation

  private

  # region Callbacks

  def destroy_previous_invitation
    self.class.find_by(member_id: member_id)&.destroy!
  end

  # endregion
end
