# frozen_string_literal: true

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

  Scope = Struct.new(:value, :text)
  SCOPE_COLLECTION = SCOPES.map { |scope| Scope.new(scope, I18n.t(scope, scope: 'admin_scope')) }.freeze

  belongs_to :user
  has_many :user_registration_forms, dependent: :delete_all, foreign_key: 'admin_id', inverse_of: :admin

  validate :scopes_must_be_included_in_list

  private

  def scopes_must_be_included_in_list
    errors.add(:scopes, :inclusion) unless (scopes - SCOPES).empty?
  end
end
