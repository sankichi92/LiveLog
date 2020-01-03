class Play < ApplicationRecord
  INSTRUMENT_ORDER = %w[Vo Vn Vla Vc Fl Cl Sax Tp Hr Tb Harp Gt Koto Pf Acc 鍵ハ Ba Cj Dr Bongo Perc].freeze

  belongs_to :member, counter_cache: true
  belongs_to :song, touch: true

  # FIXME: https://github.com/sankichi92/LiveLog/issues/118
  # validates :member_id, uniqueness: { scope: :song_id }

  before_save :format_instrument

  def self.count_by_divided_instrument
    instrument_to_count = group(:instrument).count
    single_instrument_to_count = instrument_to_count.select { |instrument, _| instrument.present? && !instrument.include?('&') }
    multi_instrument_to_count = instrument_to_count.select { |instrument, _| instrument.present? && instrument.include?('&') }
    divided_instrument_to_count = multi_instrument_to_count.each_with_object(Hash.new(0)) do |(instrument, count), hash|
      instrument.split('&').each { |divided_instrument| hash[divided_instrument] += count }
    end
    resolved_instrument_to_count = single_instrument_to_count.merge(divided_instrument_to_count) do |_, single_count, divided_count|
      single_count + divided_count
    end
    resolved_instrument_to_count.sort_by { |_, count| -count }.to_h
  end

  def self.count_formations
    group(:song_id).count.each_with_object(Hash.new(0)) { |(_, count), hash| hash[count] += 1 }.sort
  end

  def self.instruments_for_suggestion
    group(:instrument).order(count_all: :desc).having('count(*) >= 2').count.keys
  end

  def instruments
    instrument&.split('&')
  end

  def instrument_order
    INSTRUMENT_ORDER.index { |i| instrument&.include?(i) } || INSTRUMENT_ORDER.size
  end

  private

  # region Callbacks

  def format_instrument
    return if instrument.blank?
    self.instrument = instrument.tr('ａ-ｚＡ-Ｚ＆．', 'a-zA-Z&.')
    self.instrument = instrument.gsub(/(\s|\.)/, '')
  end

  # endregion
end
