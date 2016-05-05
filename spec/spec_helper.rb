require 'pathname'
require 'plist'
require 'open3'
require 'hashie'

module Helpers
  def run(sudo:, arguments:)
    command = "#{:sudo if sudo} #{macosvpn} #{arguments}"
    _, _, stderr, thread = Open3.popen3(command)
    [stderr.read, thread.value.exitstatus]
  end

  def macosvpn
    Pathname.new 'build/Release/macosvpn'
  end
end

RSpec.configure do |config|

  config.include Helpers

  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.color = true

end
