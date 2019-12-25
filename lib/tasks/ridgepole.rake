namespace :ridgepole do
  desc 'Apply db/Schemafile'
  task apply: 'db:load_config' do
    environments = [Rails.env]
    environments << 'test' if Rails.env.development?

    environments.each do |env|
      puts "For #{env}" if environments.size > 1
      ActiveRecord::Base.configurations.configs_for(env_name: env).each do |db_config|
        system 'ridgepole', '--config', db_config.config.to_json, '--file', Rails.root.join('db/Schemafile').to_s, '--allow-pk-change', '--apply'
      end
    end
  end

  desc 'Dry-run applying db/Schemafile'
  task dry_run: 'db:load_config' do
    ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).each do |db_config|
      system 'ridgepole', '--config', db_config.config.to_json, '--file', Rails.root.join('db/Schemafile').to_s, '--allow-pk-change', '--apply', '--dry-run'
    end
  end
end
