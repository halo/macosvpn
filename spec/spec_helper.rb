require 'pathname'
require 'plist'
require 'open3'
require 'hashie'

module Helpers
  def run(sudo:, arguments:)
    command = "#{:sudo if sudo} #{macosvpn} #{arguments}"
    _, stdout, stderr, thread = Open3.popen3(command)
    output = stdout.read.to_s + stderr.read.to_s
    status = thread.value.exitstatus

    [output, status]
  end

  def macosvpn
    Pathname.new 'build/Debug/macosvpn'
  end
end

RSpec.configure do |config|

  config.include Helpers

  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.color = true

end
