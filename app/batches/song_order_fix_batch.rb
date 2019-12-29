class SongOrderFixBatch < ApplicationBatch
  def run
    logger.info("Target live ids: #{target_live_ids.join(',')}")
    Live.where(id: target_live_ids).each do |live|
      live.songs.played_order.each.with_index(1) do |song, i|
        logger.info("Song id #{song.id}: #{song.time_str} #{song.order} => #{i}")
        song.update!(order: i) if ENV.fetch('DRY_RUN') == 'false'
      end
    end
  end

  def target_live_ids
    Song.connection.select_values(<<~SQL)
      select
          distinct l.live_id
      from
          songs l
          join songs r on (
            l.live_id = r.live_id
            and l.order = r.order
            and l.id != r.id
          )
    SQL
  end
end
