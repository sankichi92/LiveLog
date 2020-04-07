class Administrator < ApplicationRecord
  SCOPES = %w[
    write:lives
    write:songs
    write:members
    read:entries
    write:entries
    write:user_registration_forms
    write:admins
  ].freeze

  belongs_to :user
  has_many :user_registration_forms, dependent: :delete_all, foreign_key: 'admin_id', inverse_of: :admin

  validate :scope_must_be_included_in_list

  private

  def scope_must_be_included_in_list
    errors.add(:scope, :inclusion) unless (scope - SCOPES).empty?
  end
end
