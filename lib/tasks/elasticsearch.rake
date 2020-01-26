require 'elasticsearch/rails/tasks/import'

namespace :elasticsearch do
  namespace :import do
    desc <<~DESC
      Import published songs.

        $ rake elasticsearch:import:song

      Force rebuilding the index (delete and create):
        $ rake elasticsearch:import:song FORCE=y
    DESC
    task song: :environment do
      total_errors = Song.includes(:live, :plays).published.import(force: ENV.fetch('FORCE', false))

      puts "[IMPORT] #{total_errors} errors occurred" unless total_errors.zero?
      puts '[IMPORT] Done'
    end
  end
end
