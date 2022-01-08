# frozen_string_literal: true

class SongSearchForm
  include ActiveModel::Model

  attr_accessor :name, :artist, :instruments, :players_lower, :players_upper, :date_lower, :date_upper, :has_media, :original

  validates :players_lower, :players_upper, numericality: { only_integer: true }, allow_blank: true
  validate :valid_date

  def to_h
    instrument_arr = instruments&.tr('&', ' ')&.split(' ')&.uniq || []
    {
      name:,
      artist:,
      instruments: instrument_arr.reject { |instrument| instrument.start_with?('-') },
      excluded_instruments: instrument_arr.select { |instrument| instrument.start_with?('-') }.map { |instrument| instrument.sub('-', '') },
      players_lower: players_lower.presence&.to_i,
      players_upper: players_upper.presence&.to_i,
      date_lower: date_lower&.to_date,
      date_upper: date_upper&.to_date,
      original: original == '1',
      has_media: has_media == '1',
    }.compact
  end

  private

  # region Validations

  def valid_date
    Date.parse(date_lower) if date_lower.present?
    Date.parse(date_upper) if date_upper.present?
  rescue ArgumentError
    errors.add(:date_lower, :invalid)
  end

  # endregion
end
