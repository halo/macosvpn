# frozen_string_literal: true

require 'pathname'
require 'plist'
require 'open3'
require 'tty-command'
require 'active_support/core_ext/object/blank'

specs_path = Pathname.new File.expand_path(__dir__)
Dir[specs_path.join('support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include Quick

  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.color = true
end
