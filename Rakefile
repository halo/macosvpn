# frozen_string_literal: true
require 'tty-command'

task default: [:build]

task :build do
  TTY::Command.new.run('/usr/bin/xcodebuild',
                       '-project',
                       'macosvpn.xcodeproj',
                       '-scheme',
                       'macosvpn',
                       '-configuration',
                       'Release',
                       only_output_on_error: true)
end
