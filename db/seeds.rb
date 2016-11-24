class OldRecord < ActiveRecord::Base
  establish_connection(adapter: 'mysql2',
                       host: 'localhost',
                       username: 'live_log',
                       password: '1ive_Log',
                       database: 'live_log')
  self.abstract_class = true
end

class Member < OldRecord
end

class OldSong < OldRecord
  self.table_name = 'songs'
  belongs_to :live, class_name: 'OldLive', foreign_key: 'live_id'
end

class OldLive < OldRecord
  self.table_name = 'lives'
  has_many :songs, class_name: 'OldSong', foreign_key: 'live_id'
end

Member.all.each do |m|
  m.first_name = 'no_name' if m.first_name.blank?
  User.create!(first_name: m.first_name,
               last_name: m.last_name,
               furigana: m.furigana,
               joined: m.year,
               email: m.email,
               nickname: m.nickname,
               password_digest: m.password,
               admin: m.admin)
end

User.find(1).update_attributes(password: 'foobar',
                               password_confirmation: 'foobar',
                               activated: true,
                               activated_at: Time.zone.now)

OldLive.all.each do |l|
  live = Live.create!(name: l.name, date: l.date, place: l.place)
  l.songs.each do |s|
    begin
      live.songs.create!(name: s.name,
                         artist: s.artist,
                         youtube_id: s.url,
                         order: s.order,
                         time: s.time - 9.hour)
    rescue => e
      p e
      puts s.url
    end
  end
end
