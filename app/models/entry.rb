class Entry
  include ActiveModel::Model

  attr_accessor :applicant, :song, :preferred_rehearsal_time, :preferred_performance_time, :notes
  delegate :name, :email, :joined, to: :applicant, prefix: true
  delegate :live, :live_name, :live_title, :name, :title, :artist, :playings, to: :song

  validates :applicant, presence: true
  validates :song, presence: true

  def send_email
    EntryMailer.entry(self).deliver_now if valid?
  end
end
