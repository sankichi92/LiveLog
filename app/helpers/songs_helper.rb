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

  private

  def inst_order(inst)
    priority = INST_ORDER.index { |i| inst.include?(i) }
    priority ? priority : INST_ORDER.size
  end
end
