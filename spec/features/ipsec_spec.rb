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
      expect(status).to eq 102
    end
  end

  context 'IPSec', :sudo do
    it 'creates the VPN' do
      id = rand(9999)

      # Creating VPN for first time

      arguments = "create -c VPNTestIPSec#{id} -e vpntestipsec.example.com " \
                  '-u Alice -p p4ssw0rd -g VPNTestGroup -s s3same'
      arguments += ' --force' if quick?
      arguments += ' --debug' if verbose?
      output, status = Macosvpn.sudo arguments: arguments
      expect(output).to include "Successfully created Cisco IPSec VPN VPNTestIPSec#{id}"
      expect(status).to eq 0

      service = SCUtil::Services.find_by_name("VPNTestIPSec#{id}")
      expect(service).to be_present
      expect(service.name).to eq "VPNTestIPSec#{id}"
      expect(service.ipsec_authentication_method).to eq 'SharedSecret'
      expect(service.ipsec_shared_secret_id).to be_present
      expect(service.ipsec_local_identifier).to eq 'VPNTestGroup'
      expect(service.ipsec_local_identifier_type).to eq 'KeyID'
      expect(service.ipsec_remote_address).to eq 'vpntestipsec.example.com'
      expect(service.ipsec_shared_secret_encryption).to eq 'Keychain'
      expect(service.ipsec_xauth_name).to eq 'Alice'
      expect(service.ipsec_xauth_password_encryption).to eq 'Keychain'
      expect(service.ipsec_xauth_password_id).to be_present
      expect(service.ipsec_xauth_password_id).to end_with('XAUTH')
      expect(service.ipv4_config_method).to eq 'Automatic'
      expect(service.ipv4_override_primary).to be nil
      expect(service.interface_type).to eq 'IPSec'
      expect(service.interface_subtype).to be nil
      expect(service.ppp_auth_name).to be nil
      expect(service.ppp_auth_password_id).to be nil
      expect(service.ppp_auth_password_encryption).to be nil
      expect(service.ppp_common_remote_address).to be nil

      sleep 0.5
      key = Keychain.find(name: "VPNTestIPSec#{id}", kind: :ipsec_password)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_xauth_password_id
      expect(key.name).to eq "VPNTestIPSec#{id}"
      expect(key).to be_ipsec_password

      key = Keychain.find(name: "VPNTestIPSec#{id}", kind: :shared_secret)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_shared_secret_id
      expect(key.name).to eq "VPNTestIPSec#{id}"
      expect(key).to be_shared_secret

      key = Keychain.find(name: "VPNTestIPSec#{id}", kind: :l2tp_password)
      expect(key).to be_nil

      # VPN already exists, not overwriting

      arguments = "create -c VPNTestIPSec#{id} -e northpole.example.com -u Bob -p letm3in -g MyGroup -s s3cret"
      arguments += ' --debug' if verbose?
      output, status = Macosvpn.sudo arguments: arguments
      expect(output).to include "You already have a service with the name `VPNTestIPSec#{id}`"
      expect(output).to include 'If you want me to overwrite it'
      expect(status).to eq 73

      # Expect nothing to have changed

      service = SCUtil::Services.find_by_name("VPNTestIPSec#{id}")
      expect(service).to be_present
      expect(service.name).to eq "VPNTestIPSec#{id}"
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

      key = Keychain.find(name: "VPNTestIPSec#{id}", kind: :ipsec_password)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_xauth_password_id
      expect(key.name).to eq "VPNTestIPSec#{id}"
      expect(key).to be_ipsec_password

      key = Keychain.find(name: "VPNTestIPSec#{id}", kind: :shared_secret)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_shared_secret_id
      expect(key.name).to eq "VPNTestIPSec#{id}"
      expect(key).to be_shared_secret

      key = Keychain.find(name: "VPNTestIPSec#{id}", kind: :l2tp_password)
      expect(key).to be_nil

      # Overwriting existing VPN
      # Creating two VPNs at the same time

      arguments = "create -c VPNTestIPSec#{id} -e southpole.example.com " \
                  '-u Carol -p letm3in -g VPNTestNewGroup -s s3cret --force'
      arguments += " -c VPNTestIPSec2#{id} -e northpole.example.com -u Eve -p s3cret -s b0bby"
      arguments += ' --debug' if verbose?
      output, status = Macosvpn.sudo arguments: arguments
      expect(output).to include "You already have a service with the name `VPNTestIPSec#{id}"
      expect(output).to include "Successfully created Cisco IPSec VPN VPNTestIPSec#{id}"
      expect(status).to eq 0

      service = SCUtil::Services.find_by_name("VPNTestIPSec#{id}")
      expect(service).to be_present
      expect(service.name).to eq "VPNTestIPSec#{id}"
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
      key = Keychain.find(name: "VPNTestIPSec#{id}", kind: :ipsec_password)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_xauth_password_id
      expect(key.name).to eq "VPNTestIPSec#{id}"
      expect(key).to be_ipsec_password

      key = Keychain.find(name: "VPNTestIPSec#{id}", kind: :shared_secret)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_shared_secret_id
      expect(key.name).to eq "VPNTestIPSec#{id}"
      expect(key).to be_shared_secret

      key = Keychain.find(name: 'VPNTestIPSec', kind: :l2tp_password)
      expect(key).to be_nil

      service = SCUtil::Services.find_by_name("VPNTestIPSec2#{id}")
      expect(service).to be_present
      expect(service.name).to eq "VPNTestIPSec2#{id}"
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

      key = Keychain.find(name: "VPNTestIPSec2#{id}", kind: :ipsec_password)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_xauth_password_id
      expect(key.name).to eq "VPNTestIPSec2#{id}"
      expect(key).to be_ipsec_password

      key = Keychain.find(name: "VPNTestIPSec2#{id}", kind: :shared_secret)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_shared_secret_id
      expect(key.name).to eq "VPNTestIPSec2#{id}"
      expect(key).to be_shared_secret

      # Removing the Group

      arguments = "create -c VPNTestIPSec#{id} -e paris.example.com -u Eric -p letm3in -s s3cret --force"
      output, status = Macosvpn.sudo arguments: arguments
      expect(output).to include "You already have a service with the name `VPNTestIPSec#{id}`"
      expect(output).to include "Successfully created Cisco IPSec VPN VPNTestIPSec#{id}"
      expect(status).to eq 0

      service = SCUtil::Services.find_by_name("VPNTestIPSec#{id}")
      expect(service).to be_present
      expect(service.name).to eq "VPNTestIPSec#{id}"
      expect(service.ipsec_local_identifier).to be_nil
      expect(service.ipsec_local_identifier_type).to be nil
      expect(service.ipsec_remote_address).to eq 'paris.example.com'
      expect(service.ipsec_xauth_name).to eq 'Eric'

      # Deleting services with sudo
      # It's not possible I think to test the non-sudo mode, which still should work.
      arguments = "delete -n VPNTestIPSec#{id} --name VPNTestIPSec2#{id}"
      output, status = Macosvpn.sudo arguments: arguments
      expect(output).to include "Successfully deleted VPN Service VPNTestIPSec#{id}"
      expect(output).to include "Successfully deleted VPN Service VPNTestIPSec2#{id}"
      expect(status).to eq 0
    end
  end
end
