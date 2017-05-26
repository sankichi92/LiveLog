module SongsHelper

  def can_watch?(song)
    (logged_in? && current_user.played?(song)) ||
      ((song.open? || song.closed? && logged_in?) && !song.youtube_id.blank?)
  end

  def can_edit?(song)
    logged_in? && (current_user.admin_or_elder? || current_user.played?(song))
  end

  def button_to_add_member(text, f)
    fields = f.fields_for(:playings, @song.playings.build) do |builder|
      render 'playings_fields', f: builder
    end
    content_tag :button, text, id: 'add-member', type: 'button', class: 'btn btn-link', data: {fields: fields.gsub("\n", '')}
  end
end
