# frozen_string_literal: true

require 'app_auth0_client'

class Auth0BulkUserImportBatch < ApplicationBatch
  CONNECTION_ID = 'con_gigtZP3cyoi6Dtik'

  def run
    users = User.includes(:member).where.not(password_digest: nil)

    target_users = []
    skipped_users = []

    users.each do |user|
      begin
        user.fetch_auth0_user!
        skipped_users << user
      rescue Auth0::NotFound
        target_users << user
      end
      sleep 0.5
    end

    logger.info "Skipped users: #{skipped_users.map(&:id).join(',')}"
    raise "Unexpected target_users size: #{target_users.size}" if target_users.empty? || target_users.size > 16

    logger.info "Importing users: #{target_users.map(&:id).join(',')}"
    users_json = target_users.map { |user| convert_to_json(user) }.to_json

    # https://github.com/auth0/ruby-auth0/blob/79f5a27abe2f2f5d0b4624548e559669d1c99a40/spec/integration/lib/auth0/api/v2/api_jobs_spec.rb#L27-L28
    file_name = Rails.root.join('tmp/auth0_build_user_import_batch.json')
    File.open(file_name, 'w+') { |file| file.write(users_json) }
    File.open(file_name, 'rb') do |file|
      job = AppAuth0Client.instance.import_users(file, CONNECTION_ID)
      logger.info "Created job: #{job}"
    end
  end

  private

  def convert_to_json(user)
    {
      user_id: user.id.to_s,
      name: user.member.name,
      email: user.email,
      email_verified: true,
      custom_password_hash: {
        algorithm: 'bcrypt',
        hash: {
          value: user.password_digest,
        },
      },
      user_metadata: {
        livelog_email_notifications: user.subscribing,
      },
      app_metadata: {
        joined_year: user.member.joined_year,
        livelog_member_id: user.member.id,
      },
    }
  end
end
