# frozen_string_literal: true

Dir[Rails.root.join('lib/extensions/*.rb')].each do |file|
  require file
end
