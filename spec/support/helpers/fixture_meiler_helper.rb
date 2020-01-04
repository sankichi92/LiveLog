module FixtureMailerHelper
  def read_fixture(action)
    Rails.root.join('spec', 'fixtures', self.class.mailer_class.name.underscore, action).read
  end
end
