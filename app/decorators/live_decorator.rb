# frozen_string_literal: true

module LiveDecorator
  def at_place
    place.present? ? "@#{place}" : ''
  end

  def date_and_place
    "#{l date} #{at_place}"
  end

  def status_badge
    if published?
      tag.span('公開済み', class: 'badge badge-primary')
    elsif entry_guideline&.open?
      tag.span('エントリー募集中', class: 'badge badge-success')
    elsif entry_guideline&.closed?
      tag.span('エントリー締切', class: 'badge badge-secondary')
    else
      tag.span('未公開', class: 'badge badge-warning')
    end
  end
end
