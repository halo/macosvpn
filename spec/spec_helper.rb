require 'pathname'

module Helpers
  def run(arguments = '')
    _, _, stderr, thread = Open3.popen3("#{macosvpn} #{arguments}")
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
