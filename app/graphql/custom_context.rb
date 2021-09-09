# frozen_string_literal: true

class CustomContext < GraphQL::Query::Context
  include Rails.application.routes.url_helpers

  def auth_payload
    self[:auth_payload] || {}
  end

  def current_user
    self[:current_user]
  end

  def current_client
    self[:current_client]
  end

  def scope?(scope)
    auth_payload[:scope].to_s.split.include?(scope)
  end

  private

  def default_url_options
    self[:url_options] || { protocol: :https, host: 'livelog.ku-unplugged.net' }
  end
end
