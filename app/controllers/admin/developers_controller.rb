module Admin
  class DevelopersController < AdminController
    def index
      @developers = Developer.eager_load(user: :member).order('members.joined_year': :desc, 'members.plays_count': :desc)
    end
  end
end
