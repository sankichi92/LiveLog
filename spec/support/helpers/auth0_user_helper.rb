module Auth0UserHelper
  def stub_auth0_user(user, fields: Auth0User::DEFAULT_FIELDS, email: Faker::Internet.email, subscribing: true)
    allow(auth0_client_double).to receive(:user).with(
      user.auth0_id,
      fields: fields,
    ).and_return(
      {
        'email' => email,
        'email_verified' => true,
        'user_metadata' => {
          'livelog_member_id' => user.member.id,
          'joined_year' => user.member.joined_year,
          'subscribing' => subscribing,
        },
        'last_login' => Time.zone.now.iso8601,
      }.slice(*fields.split(',')),
    )
  end

  private

  def auth0_client_double
    @auth0_client_double ||= double(:auth0_client).tap do |auth0_client|
      allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)
    end
  end
end
