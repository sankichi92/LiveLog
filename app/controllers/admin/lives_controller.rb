module Admin
  class LivesController < AdminController
    def index(year = Live.maximum(:date).nendo)
      @year = year.to_i
      @lives = Live.nendo(@year).newest_order
    end
  end
end
