# frozen_string_literal: true

class CustomContext < GraphQL::Query::Context
  def_delegators :controller, :url_for

  def auth_payload
    self[:auth_payload] || {}
  end

  def current_user
    self[:current_user]
  end

  def current_client
    self[:current_client]
  end

  def scopes
    auth_payload[:scope].to_s.split
  end

  def scope?(scope)
    if scope.blank?
      true
    else
      scopes.include?(scope)
    end
  end

  private

  def controller
    self[:controller]
  end
end
