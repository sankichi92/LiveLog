class Song < ApplicationRecord
  belongs_to :live
  default_scope { order(:order) }
  validates :live_id, presence: true
  validates :name, presence: true
  VALID_YOUTUBE_REGEX =
      %r(\A
         (?:https?://)?
         (?:www\.youtube\.com/watch\?(?:\S*&)*v=
          |youtu\.be/)
         (?<id>\S{11})
        )x
  validates :youtube_id, format: {with: VALID_YOUTUBE_REGEX}, allow_blank: true
  before_save :extract_youtube_id

  def extract_youtube_id
    unless youtube_id.blank?
      m = youtube_id.match(VALID_YOUTUBE_REGEX)
      self.youtube_id = m[:id]
    end
  end
end
