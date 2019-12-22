module Admin
  class MembersController < AdminController
    def index
      @members = Member.includes(:user).order(id: :desc)
    end
  end
end
