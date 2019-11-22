module FixtureMailerHelper
  def read_fixture(action)
    IO.read(Rails.root.join('spec', 'fixtures', self.class.mailer_class.name.underscore, action))
  end
end
