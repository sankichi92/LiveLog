# frozen_string_literal: true

def ridgepole_apply(env = Rails.env, dry_run: false)
  options = %W[
    --config config/database.yml
    --file db/Schemafile
    --env #{env}
    --apply
  ]
  options << '--dry-run' if dry_run
  sh 'ridgepole', *options
end

namespace :ridgepole do
  desc 'Updates the DB schema according to db/Schemafile'
  task apply: :environment do
    ridgepole_apply
    ridgepole_apply('test') if Rails.env.development?
  end

  desc 'Display SQLs for DB schema update without executing them'
  task 'dry-run': :environment do
    ridgepole_apply(dry_run: true)
  end

  desc 'Creates the database, loads the schema, and initializes with the seed data if database does not exist, or updates the schema if it does'
  task prepare: :environment do
    seed = false

    begin
      ActiveRecord::Base.connection
    rescue ActiveRecord::NoDatabaseError
      ActiveRecord::Tasks::DatabaseTasks.create_current
      seed = true
    end

    ridgepole_apply
    ridgepole_apply('test') if Rails.env.development?

    ActiveRecord::Base.establish_connection
    ActiveRecord::Tasks::DatabaseTasks.load_seed if seed
  end
end
