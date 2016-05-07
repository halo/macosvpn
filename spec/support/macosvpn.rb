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

  def self.executable
    Pathname.new 'build/Debug/macosvpn'
  end

end
