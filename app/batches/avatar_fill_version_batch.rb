# frozen_string_literal: true

class AvatarFillVersionBatch < ApplicationBatch
  def run
    Avatar.find_in_batches do |avatars|
      Avatar.transaction do
        avatars.each do |avatar|
          avatar.update_column(:version, avatar.metadata['version']) # rubocop:disable Rails/SkipsModelValidations
        end
      end
    end
  end
end
