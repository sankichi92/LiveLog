module Api::V1::ApplicationHelper
  include Api::V1::TokensHelper
  include SongsHelper

  def can_watch?(song)
    !song.youtube_id.blank? &&
      (song.open? ||
        song.closed? && authenticated? ||
        authenticated? && current_user.played?(song)
      )
  end
end
