# frozen_string_literal: true

class Donation < ApplicationRecord
  MONTHLY_COST = 50

  belongs_to :member

  def active?(on: Time.zone.today)
    on <= expires_on
  end

  def expires_on
    donated_on + active_duration
  end

  def active_duration
    (amount / MONTHLY_COST).months
  end
end
