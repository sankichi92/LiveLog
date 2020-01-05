module Admin
  class EntriesController < AdminController
    def index(playable_time = nil)
      entries = Entry.preload(:member, :playable_times, song: [:live, { plays: :member }]).order(id: :desc)
      @entries = if (parsed_playable_time = Time.zone.parse(playable_time.to_s))
                   entries.joins(:playable_times).merge(PlayableTime.contains(parsed_playable_time))
                 else
                   entries
                 end
    end
  end
end
