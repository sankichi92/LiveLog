module Api::V1::ApplicationHelper
  include Api::V1::TokensHelper
  include SongsHelper # To include `sort_by_inst`, which is used in SongsController#show

  def can_watch?(song)
    song.open? ||
      song.closed? && authenticated? ||
      authenticated? && @current_user.played?(song)
  end
end
