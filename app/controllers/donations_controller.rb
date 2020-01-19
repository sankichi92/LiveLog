class DonationsController < ApplicationController
  before_action :require_current_user

  def index
    @donations = Donation.order(:donated_on)
  end
end
