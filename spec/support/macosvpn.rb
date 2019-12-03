# frozen_string_literal: true

module Macosvpn
  def self.call(arguments:)
    run "#{executable} #{arguments}"
  end

  def self.sudo(arguments:)
    run "sudo #{executable} #{arguments}"
  end

  def self.run(command)
    _, stdout, stderr, thread = Open3.popen3(command)
    output = stdout.read.to_s + stderr.read.to_s
    status = thread.value.exitstatus

    [output, status]
  end
  private_class_method :run

  def self.executable
    return @executable if defined?(@executable)
    result = TTY::Command.new.run('/usr/bin/xcodebuild -project macosvpn.xcodeproj -showBuildSettings', only_output_on_error: true)
    settings = result.out.split
    target_build_dir = settings[settings.find_index('TARGET_BUILD_DIR') + 2]

    @executable = Pathname.new(target_build_dir).join('macosvpn')
  end
  private_class_method :executable
end
