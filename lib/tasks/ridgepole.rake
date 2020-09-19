# frozen_string_literal: true

namespace :ridgepole do
  desc 'Run `ridgepole --apply`'
  task apply: 'db:load_config' do
    environments = [Rails.env]
    environments << 'test' if Rails.env.development?

    environments.each do |env|
      puts "=== #{env} ===" if environments.size > 1
      ActiveRecord::Base.configurations.configs_for(env_name: env).each do |db_config|
        system 'ridgepole', '--config', db_config.config.to_json, '--file', Rails.root.join('db/ridgepole.rb').to_s, '--apply'
      end
    end
  end

  desc 'Run `ridgepole --apply --dru-run`'
  task dry_run: 'db:load_config' do
    ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).each do |db_config|
      system 'ridgepole', '--config', db_config.config.to_json, '--file', Rails.root.join('db/ridgepole.rb').to_s, '--apply', '--dry-run'
    end
  end
end
