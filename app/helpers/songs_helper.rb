module SongsHelper
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
      original: options[:original] ? '1' : '0',
    )
    block_given? ? link_to(options, html_options, &block) : link_to(name, options, html_options)
  end
end
