class Playing < ApplicationRecord
  INST_ORDER = %w[Vo Vn Vla Vc Fl Cl Sax Tp Hr Tb Harp Gt Koto Pf Acc 鍵ハ Ba Cj Dr Bongo Perc].freeze

  belongs_to :user, counter_cache: true
  belongs_to :song, touch: true

  delegate :handle, :name, :joined, :email, :public?, to: :user

  before_save :format_inst

  validates :user_id, presence: true
  validates :song, presence: true

  scope :published, -> { includes(song: :live).where('lives.published': true) }

  def self.count_insts
    inst_to_count = group(:inst).count
    single_inst_to_count = inst_to_count.select { |inst, _| inst.present? && !inst.include?('&') }
    multi_inst_to_count = inst_to_count.select { |inst, _| inst.present? && inst.include?('&') }
    divided_inst_to_count = multi_inst_to_count.each_with_object(Hash.new(0)) do |(inst, count), hash|
      inst.split('&').each { |divided_inst| hash[divided_inst] += count }
    end
    resolved_inst_to_count = single_inst_to_count.merge(divided_inst_to_count) do |_, single_count, divided_count|
      single_count + divided_count
    end
    resolved_inst_to_count.sort_by { |_, count| -count }
  end

  def self.count_formations
    group(:song_id).count.each_with_object(Hash.new(0)) { |(_, count), hash| hash[count] += 1 }.sort
  end

  def self.insts_for_suggestion
    group(:inst).order(count: :desc).having('playings.count >= 2').count.keys
  end

  def instruments
    inst&.split('&')
  end

  def inst_order
    INST_ORDER.index { |i| inst&.include?(i) } || INST_ORDER.size
  end

  private

  def format_inst
    return if inst.blank?
    self.inst = inst.tr('ａ-ｚＡ-Ｚ＆．', 'a-zA-Z&.')
    self.inst = inst.gsub(/(\s|\.)/, '')
  end
end
