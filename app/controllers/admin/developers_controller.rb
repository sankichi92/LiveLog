module Admin
  class DevelopersController < AdminController
    def index
      @developers = Developer.includes(:clients).eager_load(user: :member).order('members.joined_year': :desc, 'members.plays_count': :desc)
    end
  end
end
