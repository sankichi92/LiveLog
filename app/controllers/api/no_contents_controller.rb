module API
  class NoContentsController < APIController
    before_action -> { require_scope('read:public') }

    def show
      head :no_content
    end
  end
end
