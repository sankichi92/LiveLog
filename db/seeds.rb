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

Member.all.each do |m|
  User.new(first_name: m.first_name,
           last_name: m.last_name,
           furigana: m.furigana,
           joined: m.year,
           email: m.email,
           nickname: m.nickname,
           password_digest: m.password,
           admin: m.admin).save!(validate: false)
end
