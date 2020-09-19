# frozen_string_literal: true

Dir[File.expand_path('schemas/**/*.schema', __dir__)].sort.each do |schema|
  require schema
end
