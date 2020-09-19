# frozen_string_literal: true

def ridgepole_apply(environment = Rails.env, dry_run: false)
  environments = [environment]
  environments << 'test' if !dry_run && environment == 'development'

  environments.each do |env|
    puts "For #{env}" if environments.size > 1
    ActiveRecord::Base.configurations.configs_for(env_name: env).each do |db_config|
      args = [
        '--config', db_config.config.to_json,
        '--file', Rails.root.join(db_config.config['schemafile_path'] || 'db/Schemafile').to_s,
        '--apply',
      ]
      args << '--dry-run' if dry_run
      system('ridgepole', *args) || abort
    end
  end
end

namespace :ridgepole do
  desc 'Runs `ridgepole --apply`'
  task apply: 'db:load_config' do
    ridgepole_apply
  end

  desc 'Runs `ridgepole --apply --dru-run`'
  task 'dry-run': 'db:load_config' do
    ridgepole_apply(dry_run: true)
  end

  desc 'Runs db:create and db:seed around `ridgepole --apply` if database does not exist (like db:prepare)'
  task prepare: 'db:load_config' do
    seed = false

    begin
      ActiveRecord::Base.connection
    rescue ActiveRecord::NoDatabaseError
      ActiveRecord::Tasks::DatabaseTasks.create_current
      seed = true
    end

    ridgepole_apply

    ActiveRecord::Base.establish_connection
    ActiveRecord::Tasks::DatabaseTasks.load_seed if seed
  end
end
