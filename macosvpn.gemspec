plist_path = File.expand_path('../macosvpn/Info.plist', __FILE__)
version = File.read(plist_path).match(%r{CFBundleVersion<\/key>\s*<string>([0-9.]{5})})[1]

Gem::Specification.new do |spec|

  spec.name         = 'macosvpn'
  spec.authors      = %w{ funkensturm }
  spec.version      = version
  spec.summary      = 'Mac OS: Create L2TP over IPSec VPNs programmatically.'
  spec.description  = 'Command-line tool to create L2TP over IPSec VPN services programmatically in Mac OS X.'
  spec.homepage     = 'https://github.com/halo/macosvpn'
  spec.license      = 'MIT'

  spec.files        = Dir['{bin}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
  spec.executables = %w{ macosvpn }

  spec.platform = Gem::Platform.local

end
