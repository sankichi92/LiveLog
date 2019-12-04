require 'app_auth0_client'

class Auth0BulkUserImportBatch < ApplicationBatch
  def run
    connections = AppAuth0Client.instance.connections(fields: %w[id name])
    connection_id = connections.find { |con| con.fetch('name') == User::AUTH0_UP_AUTH_CONNECTION }.fetch('id')

    User.includes(:member).where.not(password_digest: nil, email: nil).find_in_batches(batch_size: 50, start: 103) do |users|
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
      next if target_users.empty?

      logger.info "Importing users: #{target_users.map(&:id).join(',')}"
      users_json = target_users.map { |user| convert_to_json(user) }.to_json

      # https://github.com/auth0/ruby-auth0/blob/79f5a27abe2f2f5d0b4624548e559669d1c99a40/spec/integration/lib/auth0/api/v2/api_jobs_spec.rb#L27-L28
      file_name = Rails.root.join("tmp/auth0_users_json_#{target_users.first.id}-#{target_users.last.id}.json")
      File.open(file_name, 'w+') { |file| file.write(users_json) }
      File.open(file_name, 'rb') do |users_file|
        job = AppAuth0Client.instance.import_users(users_file, connection_id)
        logger.info "Created job: #{job}"
      end

      sleep 1
    end
  end

  private

  def convert_to_json(user)
    {
      name: user.member.name,
      user_id: user.id.to_s,
      email: user.email,
      email_verified: true,
      password_hash: user.password_digest,
      user_metadata: {
        livelog_member_id: user.member.id,
        joined_year: user.member.joined_year,
        subscribing: user.subscribing,
      },
    }
  end
end
