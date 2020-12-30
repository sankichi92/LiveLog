# frozen_string_literal: true

class ApplicationBatch
  class_attribute :logger, instance_writer: false

  self.logger = Rails.logger
end
