module SongsHelper
  def button_to_add_member(form)
    fields = form.fields_for(:playings, form.object.playings.build) do |builder|
      render 'songs/inputs/playings_fields', f: builder
    end
    content_tag :button,
                icon('fas', 'plus') + ' ' + 'メンバーを追加する',
                id: 'add-member', type: 'button', class: 'btn btn-light', data: { fields: fields.delete("\n") }
  end

  def link_to_search(name, options = nil, html_options = nil, &block)
    if block_given?
      html_options = options
      options = name
    end
    options = search_songs_path(
      name: options[:name],
      artist: options[:artist],
      instruments: options[:instruments],
      players_lower: options[:players_count],
      players_upper: options[:players_count],
      date_lower: options[:date_range]&.begin,
      date_upper: options[:date_range]&.end,
      user_id: options[:user_id],
    ) + '#results'
    block_given? ? link_to(options, html_options, &block) : link_to(name, options, html_options)
  end
end
