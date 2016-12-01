class Playing < ApplicationRecord
  belongs_to :user
  belongs_to :song
  scope :order_by_inst, -> { order(case_str) }
  scope :count_insts, -> { group(:inst).count(:id) }
  scope :count_members_per_song, -> { group(:song_id).count(:id) }
  before_save :format_inst
  validates :user_id, presence: true
  validates :song, presence: true
  INST_ORDER = %w(Vo Vn Vc Fl Cl Sax Tp Hr Tb Harp Gt Koto Pf Acc 鍵ハ Ba Cj Dr Bongo Perc)

  def Playing.case_str
    ret = 'CASE'
    INST_ORDER.each_with_index do |p, i|
      ret << " WHEN inst LIKE '%#{p}%' THEN #{i}"
    end
    ret << ' END'
  end

  def Playing.resolve_insts(inst_counts)
    singles = inst_counts.reject { |inst, count| inst.blank? || inst.include?('&') }
    multis = inst_counts.select { |inst, count| !inst.blank? && inst.include?('&') }
    resolved = multis.each_with_object(Hash.new(0)) do |(insts, count), hash|
      insts.split('&').each { |inst| hash[inst] += count }
    end
    merged = singles.merge(resolved) do |inst, single_count, resolved_count|
      single_count + resolved_count
    end
    merged.sort { |(k1, v1), (k2, v2)| v2 <=> v1 }
  end

  def Playing.count_formation(member_counts)
    member_counts.each_with_object(Hash.new(0)) { |(id, count), hash| hash[count] += 1 }.sort
  end

  def format_inst
    unless inst.blank?
      self.inst = inst.tr('ａ-ｚＡ-Ｚ＆．', 'a-zA-Z&.')
      self.inst = inst.gsub(/(\s|\.)/, '')
    end
  end
end
