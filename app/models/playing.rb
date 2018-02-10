class Playing < ApplicationRecord
  belongs_to :user
  belongs_to :song, touch: true

  delegate :handle, :name, :display_name, :joined, :email, :public?, to: :user

  before_save :format_inst

  validates :user_id, presence: true
  validates :song, presence: true

  scope :published, -> { includes(song: :live).where('lives.published': true) }

  scope :count_insts, lambda {
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
  }

  scope :count_formations, lambda {
    group(:song_id).count.each_with_object(Hash.new(0)) { |(_, count), hash| hash[count] += 1 }.sort
  }

  def instruments
    inst&.split('&')
  end

  private

  def format_inst
    return if inst.blank?
    self.inst = inst.tr('ａ-ｚＡ-Ｚ＆．', 'a-zA-Z&.')
    self.inst = inst.gsub(/(\s|\.)/, '')
  end
end
