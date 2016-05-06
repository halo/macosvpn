require 'spec_helper'

RSpec.describe 'Creating a VPN Service' do

  context 'no sudo' do
    it 'warns about the missing permissions' do
      arguments = 'create -c Atlantis -e atlantic.example.com -u Alice -p p4ssw0rd -g EasyVPNGroup -s s3same'
      output, status = run sudo: false, arguments: arguments
      expect(output).to include 'without superuser privileges'
      expect(output).to include 'thus cannot create'
      expect(status).to eq 31
    end
  end

  context 'creating an IPSec VPN', :sudo do
    it 'creates the VPN' do
      plist = Hashie::Mash.new Plist.parse_xml('/Library/Preferences/SystemConfiguration/preferences.plist')
      service_names = plist.NetworkServices.values.map(&:UserDefinedName)
      raise 'Please remove the `Atlantis` VPN manually first.' if service_names.include?('Atlantis')

      arguments = 'create -c Atlantis -e atlantic2.example.com -u Alice -p p4ssw0rd -g AtlantisGroup -s s3same --force --debug'
      output, status = run sudo: true, arguments: arguments
      expect(output).to include 'Successfully created Cisco IPSec VPN Atlantis'
      expect(status).to eq 0

      plist = Hashie::Mash.new Plist.parse_xml('/Library/Preferences/SystemConfiguration/preferences.plist')
      service_names = plist.NetworkServices.values.map(&:UserDefinedName)
      expect(service_names).to eq service_names.compact
      expect(service_names).to include 'Atlantis'
    end
  end

end
