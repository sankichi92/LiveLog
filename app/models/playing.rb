class Playing < ApplicationRecord
  belongs_to :user
  belongs_to :song, touch: true

  before_save :format_inst

  validates :user_id, presence: true
  validates :song, presence: true

  scope :count_insts, -> { group(:inst).count(:id) }
  scope :count_members_per_song, -> { group(:song_id).count(:id) }

  def self.resolve_insts(inst_to_count)
    single_inst_to_count = inst_to_count.reject { |inst, _| inst.blank? || inst.include?('&') }
    multi_inst_to_count = inst_to_count.select { |inst, _| !inst.blank? && inst.include?('&') }
    divided_inst_to_count = multi_inst_to_count.each_with_object(Hash.new(0)) do |(inst, count), hash|
      inst.split('&').each { |divided_inst| hash[divided_inst] += count }
    end
    resolved_inst_to_count = single_inst_to_count.merge(divided_inst_to_count) do |_, single_count, divided_count|
      single_count + divided_count
    end
    resolved_inst_to_count.sort_by { |_, count| count }.reverse
  end

  def self.count_formation(member_counts)
    member_counts.each_with_object(Hash.new(0)) do |(_, count), hash|
      hash[count] += 1
    end.sort
  end

  private

  def format_inst
    return if inst.blank?
    self.inst = inst.tr('ａ-ｚＡ-Ｚ＆．', 'a-zA-Z&.')
    self.inst = inst.gsub(/(\s|\.)/, '')
  end
end
