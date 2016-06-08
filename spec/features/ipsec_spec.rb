require 'spec_helper'

RSpec.describe 'Creating a VPN Service' do

  context 'IPSec', :sudo do
    it 'creates the VPN' do
      raise 'Please remove the `VPNTestIPSec` VPN manually.' if slow? && SCUtil::Services.find_by_name('VPNTestIPSec')
      raise 'Please remove the Keychain Item `VPNTestIPSec` manually.' if slow? && Keychain.find(name: 'VPNTestIPSec', kind: :any)

      # Creating VPN for first time

      arguments = 'create -c VPNTestIPSec -e vpntestipsec.example.com -u Alice -p p4ssw0rd -g VPNTestGroup -s s3same'
      arguments += ' --force' if quick?
      output, status = Macosvpn.sudo arguments: arguments
      expect(output).to include 'Successfully created Cisco IPSec VPN VPNTestIPSec'
      expect(status).to eq 0

      service = SCUtil::Services.find_by_name('VPNTestIPSec')
      expect(service).to be_present
      expect(service.name).to eq 'VPNTestIPSec'
      expect(service.ipsec_authentication_method).to eq 'SharedSecret'
      expect(service.ipsec_shared_secret_id).to be_present
      expect(service.ipsec_local_identifier).to eq 'VPNTestGroup'
      expect(service.ipsec_local_identifier_type).to eq 'KeyID'
      expect(service.ipsec_remote_address).to eq 'vpntestipsec.example.com'
      expect(service.ipsec_shared_secret_encryption).to eq 'Keychain'
      expect(service.ipsec_xauth_name).to eq 'Alice'
      expect(service.ipsec_xauth_password_encryption).to eq 'Keychain'
      expect(service.ipsec_xauth_password_id).to be_present
      expect(service.ipv4_config_method).to eq 'PPP'
      expect(service.ipv4_override_primary).to eq 1
      expect(service.interface_type).to eq 'IPSec'
      expect(service.interface_subtype).to be nil
      expect(service.ppp_auth_name).to be nil
      expect(service.ppp_auth_password_id).to be nil
      expect(service.ppp_auth_password_encryption).to be nil
      expect(service.ppp_common_remote_address).to be nil

      sleep 0.5
      key = Keychain.find(name: 'VPNTestIPSec', kind: :ipsec_password)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_xauth_password_id
      expect(key.name).to eq 'VPNTestIPSec'
      expect(key).to be_ipsec_password

      key = Keychain.find(name: 'VPNTestIPSec', kind: :shared_secret)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_shared_secret_id
      expect(key.name).to eq 'VPNTestIPSec'
      expect(key).to be_shared_secret

      key = Keychain.find(name: 'VPNTestIPSec', kind: :l2tp_password)
      expect(key).to be_nil

      # VPN already exists, not overwriting

      arguments = 'create -c VPNTestIPSec -e northpole.example.com -u Bob -p letm3in -g MyGroup -s s3cret'
      output, status = Macosvpn.sudo arguments: arguments
      expect(output).to include 'You already have a service VPNTestIPSec'
      expect(output).to include 'If you want me to overwrite it'
      expect(status).to eq 44

      # Expect nothing to have changed

      service = SCUtil::Services.find_by_name('VPNTestIPSec')
      expect(service).to be_present
      expect(service.name).to eq 'VPNTestIPSec'
      expect(service.ipsec_authentication_method).to eq 'SharedSecret'
      expect(service.ipsec_local_identifier).to eq 'VPNTestGroup'
      expect(service.ipsec_local_identifier_type).to eq 'KeyID'
      expect(service.ipsec_remote_address).to eq 'vpntestipsec.example.com'
      expect(service.ipsec_shared_secret_encryption).to eq 'Keychain'
      expect(service.ipsec_xauth_name).to eq 'Alice'
      expect(service.ipsec_xauth_password_encryption).to eq 'Keychain'
      expect(service.ipv4_config_method).to eq 'PPP'
      expect(service.ipv4_override_primary).to eq 1
      expect(service.interface_type).to eq 'IPSec'
      expect(service.interface_subtype).to be nil

      key = Keychain.find(name: 'VPNTestIPSec', kind: :ipsec_password)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_xauth_password_id
      expect(key.name).to eq 'VPNTestIPSec'
      expect(key).to be_ipsec_password

      key = Keychain.find(name: 'VPNTestIPSec', kind: :shared_secret)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_shared_secret_id
      expect(key.name).to eq 'VPNTestIPSec'
      expect(key).to be_shared_secret

      key = Keychain.find(name: 'VPNTestIPSec', kind: :l2tp_password)
      expect(key).to be_nil

      # Overwriting existing VPN

      arguments = 'create -c VPNTestIPSec -e southpole.example.com -u Carol -p letm3in -g VPNTestNewGroup -s s3cret --force'
      output, status = Macosvpn.sudo arguments: arguments
      expect(output).to include 'You already have a service VPNTestIPSec'
      expect(output).to include 'Successfully created Cisco IPSec VPN VPNTestIPSec'
      expect(status).to eq 0

      service = SCUtil::Services.find_by_name('VPNTestIPSec')
      expect(service).to be_present
      expect(service.name).to eq 'VPNTestIPSec'
      expect(service.ipsec_authentication_method).to eq 'SharedSecret'
      expect(service.ipsec_local_identifier).to eq 'VPNTestNewGroup'
      expect(service.ipsec_local_identifier_type).to eq 'KeyID'
      expect(service.ipsec_remote_address).to eq 'southpole.example.com'
      expect(service.ipsec_shared_secret_encryption).to eq 'Keychain'
      expect(service.ipsec_xauth_name).to eq 'Carol'
      expect(service.ipsec_xauth_password_encryption).to eq 'Keychain'
      expect(service.ipv4_config_method).to eq 'PPP'
      expect(service.ipv4_override_primary).to eq 1
      expect(service.interface_type).to eq 'IPSec'
      expect(service.interface_subtype).to be nil

      sleep 0.5
      key = Keychain.find(name: 'VPNTestIPSec', kind: :ipsec_password)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_xauth_password_id
      expect(key.name).to eq 'VPNTestIPSec'
      expect(key).to be_ipsec_password

      key = Keychain.find(name: 'VPNTestIPSec', kind: :shared_secret)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_shared_secret_id
      expect(key.name).to eq 'VPNTestIPSec'
      expect(key).to be_shared_secret

      key = Keychain.find(name: 'VPNTestIPSec', kind: :l2tp_password)
      expect(key).to be_nil

      # Removing the Group

      arguments = 'create -c VPNTestIPSec -e paris.example.com -u Eric -p letm3in -s s3cret --force'
      output, status = Macosvpn.sudo arguments: arguments
      expect(output).to include 'You already have a service VPNTestIPSec'
      expect(output).to include 'Successfully created Cisco IPSec VPN VPNTestIPSec'
      expect(status).to eq 0

      service = SCUtil::Services.find_by_name('VPNTestIPSec')
      expect(service).to be_present
      expect(service.name).to eq 'VPNTestIPSec'
      expect(service.ipsec_local_identifier).to be_nil
      expect(service.ipsec_local_identifier_type).to be nil
      expect(service.ipsec_remote_address).to eq 'paris.example.com'
      expect(service.ipsec_xauth_name).to eq 'Eric'
    end
  end

end
