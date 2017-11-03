require 'elasticsearch/rails/tasks/import'

namespace :elasticsearch do
  namespace :import do
    desc <<-DESC.gsub(/    /, '')
      Import published songs.

        $ rake environment elasticsearch:import:song

      Force rebuilding the index (delete and create):
        $ rake environment elasticsearch:import:song FORCE=y
    DESC
    task :song do
      total_errors = Song.includes(:playings).published.import force: ENV.fetch('FORCE', false)

      puts "[IMPORT] #{total_errors} errors occurred" unless total_errors.zero?
      puts '[IMPORT] Done'
    end
  end
end
