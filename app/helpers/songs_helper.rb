module SongsHelper

  def button_to_add_member(text, f)
    fields = f.fields_for(:playings, @song.playings.build) do |builder|
      render 'playings_fields', f: builder
    end
    content_tag :button, text, id: 'add-member', type: 'button', class: 'btn btn-link', data: {fields: fields.gsub("\n", '')}
  end
end
