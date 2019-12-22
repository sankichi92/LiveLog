module Admin
  class MembersController < AdminController
    def index(year = Member.maximum(:joined_year))
      @year = year.to_i
      @members = Member.includes(:user).where(joined_year: @year).order(playings_count: :desc)
    end

    def new
      @member = Member.new
    end
  end
end
