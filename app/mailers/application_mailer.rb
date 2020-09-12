# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  DEFAULT_FROM_NAME = 'LiveLog'
  DEFAULT_FROM_EMAIL = 'noreply@livelog.ku-unplugged.net'

  layout 'mailer'

  default from: %("#{DEFAULT_FROM_NAME}" <#{DEFAULT_FROM_EMAIL}>)
end
