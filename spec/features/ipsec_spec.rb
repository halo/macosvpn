# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Creating and deleting a VPN Service' do
  context 'no arguments', :sudo do
    it 'fails and is informational' do
      output, status = Macosvpn.sudo arguments: 'create'
      expect(output).to include 'You did not specify any interfaces for me to create'
      expect(status).to eq 22
    end
  end

  context 'missing endpoint', :sudo do
    it 'fails and is informational' do
      output, status = Macosvpn.sudo arguments: 'create --cisco SomeName'
      expect(output).to include 'You did not provide an endpoint'
      expect(status).to eq 21
    end
  end

  context 'IPSec', :sudo do
    it 'creates the VPN' do
      raise 'Please remove the `VPNTestIPSec` VPN manually.' if slow? && SCUtil::Services.find_by_name('VPNTestIPSec')
      raise 'Please remove the `VPNTestIPSec2` VPN manually.' if slow? && SCUtil::Services.find_by_name('VPNTestIPSec2')
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
      expect(service.ipsec_xauth_password_id).to_not include('XAUTH') # Shouldn't it?
      expect(service.ipv4_config_method).to eq 'Automatic'
      expect(service.ipv4_override_primary).to be nil
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
      expect(status).to eq 53

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
      expect(service.ipv4_config_method).to eq 'Automatic'
      expect(service.ipv4_override_primary).to be nil
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
      # Creating two VPNs at the same time

      arguments = 'create -c VPNTestIPSec -e southpole.example.com -u Carol -p letm3in -g VPNTestNewGroup -s s3cret --force'
      arguments += ' -c VPNTestIPSec2 -e northpole.example.com -u Eve -p s3cret -s b0bby'
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
      expect(service.ipv4_config_method).to eq 'Automatic'
      expect(service.ipv4_override_primary).to be nil
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

      service = SCUtil::Services.find_by_name('VPNTestIPSec2')
      expect(service).to be_present
      expect(service.name).to eq 'VPNTestIPSec2'
      expect(service.ipsec_authentication_method).to eq 'SharedSecret'
      expect(service.ipsec_local_identifier).to be nil
      expect(service.ipsec_local_identifier_type).to be nil
      expect(service.ipsec_remote_address).to eq 'northpole.example.com'
      expect(service.ipsec_shared_secret_encryption).to eq 'Keychain'
      expect(service.ipsec_xauth_name).to eq 'Eve'
      expect(service.ipsec_xauth_password_encryption).to eq 'Keychain'
      expect(service.ipv4_config_method).to eq 'Automatic'
      expect(service.ipv4_override_primary).to be nil
      expect(service.interface_type).to eq 'IPSec'
      expect(service.interface_subtype).to be nil

      key = Keychain.find(name: 'VPNTestIPSec2', kind: :ipsec_password)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_xauth_password_id
      expect(key.name).to eq 'VPNTestIPSec2'
      expect(key).to be_ipsec_password

      key = Keychain.find(name: 'VPNTestIPSec2', kind: :shared_secret)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_shared_secret_id
      expect(key.name).to eq 'VPNTestIPSec2'
      expect(key).to be_shared_secret

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

      # Deleting services with sudo
      # It's not possible I think to test the non-sudo mode, which still should work.
      arguments = 'delete -n VPNTestIPSec --name VPNTestIPSec2'
      output, status = Macosvpn.sudo arguments: arguments
      expect(output).to include 'Successfully deleted VPN Service VPNTestIPSec'
      expect(output).to include 'Successfully deleted VPN Service VPNTestIPSec2'
      expect(status).to eq 0
    end
  end
end
