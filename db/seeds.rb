class OldRecord < ActiveRecord::Base
  establish_connection(adapter: 'mysql2',
                       host: 'localhost',
                       username: 'live_log',
                       password: '1ive_Log',
                       database: 'live_log')
  self.abstract_class = true
end

class Member < OldRecord
  def kana
    furigana.gsub(/\s+/, '')
  end
end

class OldSong < OldRecord
  self.table_name = 'songs'
  has_many :members_songs, foreign_key: 'song_id'
end

class OldLive < OldRecord
  self.table_name = 'lives'
  has_many :songs, class_name: 'OldSong', foreign_key: 'live_id'
end

class MembersSong < OldRecord
  belongs_to :member
  def inst
    if sub_instrument.blank?
      instrument
    else
      "#{instrument}&#{sub_instrument}"
    end
  end
end

Member.all.each do |m|
  m.first_name = '?' if m.first_name.blank?
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
    s.time -= 9.hour unless s.time.blank?
    live.songs.create!(name: s.name,
                       artist: s.artist,
                       youtube_id: s.url,
                       order: s.order,
                       time: s.time,
                       playings_attributes: s.members_songs.map { |p|
                         {user_id: User.find_by(furigana: p.member.kana, joined: p.member.year).id,
                          inst: p.inst} })
  end
end
