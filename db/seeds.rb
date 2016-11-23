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

class OldLive < OldRecord
  self.table_name = 'lives'
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

User.first.update_attributes(password: 'foobar',
                             password_confirmation: 'foobar',
                             activated: true,
                             activated_at: Time.zone.now)

OldLive.all.each do |l|
  Live.create!(name: l.name, date: l.date, place: l.place)
end
