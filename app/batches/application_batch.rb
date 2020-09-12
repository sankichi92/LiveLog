# frozen_string_literal: true

class ApplicationBatch
  class_attribute :logger, instance_writer: false

  self.logger = if Rails.env.test?
                  Rails.logger
                else
                  ActiveSupport::Logger.new($stdout).extend(ActiveSupport::Logger.broadcast(Rails.logger))
                end
end
