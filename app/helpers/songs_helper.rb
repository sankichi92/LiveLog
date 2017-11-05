module SongsHelper
  INST_ORDER = %w[Vo Vn Vla Vc Fl Cl Sax Tp Hr Tb Harp Gt Koto Pf Acc 鍵ハ Ba Cj Dr Bongo Perc].freeze

  def sort_by_inst(playings)
    playings.sort { |p1, p2| inst_order(p1.inst) <=> inst_order(p2.inst) }
  end

  def button_to_add_member(form)
    fields = form.fields_for(:playings, @song.playings.build) do |builder|
      render 'songs/playings_fields', f: builder
    end
    content_tag :button,
                icon('plus') + ' メンバーを追加する',
                id: 'add-member', type: 'button', class: 'btn btn-light', data: { fields: fields.delete("\n") }
  end

  def status_icon(song)
    if song.open?
      icon('globe')
    elsif song.secret?
      icon('lock')
    end
  end

  def link_to_song(song)
    song.watchable?(current_user) ? link_to(song.name, song) : song.name
  end

  def link_to_search(name, options = nil, html_options = nil, &block)
    options, html_options = name, options if block_given?
    options = search_songs_path(
      artist: options[:artist],
      players_lower: options[:players_count],
      players_upper: options[:players_count],
      date_lower: options[:date_range]&.begin,
      date_upper: options[:date_range]&.end,
      user_id: options[:user_id]
    ) + '#results'
    block_given? ? link_to(options, html_options, &block) : link_to(name, options, html_options)
  end

  private

  def inst_order(inst)
    priority = INST_ORDER.index { |i| inst.include?(i) }
    priority ? priority : INST_ORDER.size
  end
end
