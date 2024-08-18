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
end
