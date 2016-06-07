require 'spec_helper'

RSpec.describe 'Creating a VPN Service' do

  context 'L2TP', :sudo do
    it 'creates the VPN' do
      raise 'Please remove the `VPNTestL2TP` VPN manually first.' if slow? && SCUtil::Services.find_by_name('VPNTestL2TP')
      raise 'Please remove the Keychain Item `VPNTestL2TP` manually first.' if slow? && Keychain.find(name: 'VPNTestL2TP', kind: :any)

      # Creating VPN for first time

      arguments = 'create -l VPNTestL2TP -e vpntestl2tp.example.com -u Alice -p p4ssw0rd -g VPNL2TPGroup -s s3same'
      arguments += ' --force' if quick?
      output, status = Macosvpn.sudo arguments: arguments
      expect(output).to include 'Successfully created L2TP over IPSec VPN VPNTestL2TP'
      expect(status).to eq 0

      service = SCUtil::Services.find_by_name('VPNTestL2TP')
      expect(service).to be_present
      expect(service.name).to eq 'VPNTestL2TP'
      expect(service.ipsec_authentication_method).to eq 'SharedSecret'
      expect(service.ipsec_shared_secret_id).to be_present
      expect(service.ipsec_shared_secret_encryption).to eq 'Keychain'
      expect(service.ipsec_local_identifier).to eq 'VPNL2TPGroup'
      expect(service.ipsec_local_identifier_type).to eq 'KeyID'
      expect(service.ipsec_remote_address).to be nil
      expect(service.ipsec_xauth_name).to be nil
      expect(service.ipsec_xauth_password_encryption).to be nil
      expect(service.ipv4_config_method).to eq 'PPP'
      expect(service.ipv4_override_primary).to eq 1
      expect(service.interface_type).to eq 'PPP'
      expect(service.interface_subtype).to eq 'L2TP'
      expect(service.ppp_auth_name).to eq 'Alice'
      expect(service.ppp_auth_password_id).to be_present
      expect(service.ppp_auth_password_encryption).to eq 'Keychain'
      expect(service.ppp_common_remote_address).to eq 'vpntestl2tp.example.com'

      sleep 0.5
      key = Keychain.find(name: 'VPNTestL2TP', kind: :l2tp_password)
      expect(key).to be_present
      expect(key.id).to eq service.ppp_auth_password_id
      expect(key.name).to eq 'VPNTestL2TP'
      expect(key).to be_l2tp_password

      key = Keychain.find(name: 'VPNTestL2TP', kind: :shared_secret)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_shared_secret_id
      expect(key.name).to eq 'VPNTestL2TP'
      expect(key).to be_shared_secret

      key = Keychain.find(name: 'VPNTestL2TP', kind: :ipsec_password)
      expect(key).to be_nil

      # VPN already exists, not overwriting

      arguments = 'create -c VPNTestL2TP -e northpole.example.com -u Bob -p letm3in -g AnotherL2TPGroup -s s3cret'
      output, status = Macosvpn.sudo arguments: arguments
      expect(output).to include 'You already have a service VPNTestL2TP'
      expect(output).to include 'If you want me to overwrite it'
      expect(status).to eq 44

      # Expect nothing to have changed

      service = SCUtil::Services.find_by_name('VPNTestL2TP')
      expect(service).to be_present
      expect(service.name).to eq 'VPNTestL2TP'
      expect(service.ipsec_authentication_method).to eq 'SharedSecret'
      expect(service.ipsec_shared_secret_id).to be_present
      expect(service.ipsec_shared_secret_encryption).to eq 'Keychain'
      expect(service.ipsec_local_identifier).to eq 'VPNL2TPGroup'
      expect(service.ipsec_local_identifier_type).to eq 'KeyID'
      expect(service.ipsec_remote_address).to be nil
      expect(service.ipsec_xauth_name).to be nil
      expect(service.ipsec_xauth_password_encryption).to be nil
      expect(service.ipv4_config_method).to eq 'PPP'
      expect(service.ipv4_override_primary).to eq 1
      expect(service.interface_type).to eq 'PPP'
      expect(service.interface_subtype).to eq 'L2TP'
      expect(service.ppp_auth_name).to eq 'Alice'
      expect(service.ppp_auth_password_id).to be_present
      expect(service.ppp_auth_password_encryption).to eq 'Keychain'
      expect(service.ppp_common_remote_address).to eq 'vpntestl2tp.example.com'

      sleep 0.5
      key = Keychain.find(name: 'VPNTestL2TP', kind: :l2tp_password)
      expect(key).to be_present
      expect(key.id).to eq service.ppp_auth_password_id
      expect(key.name).to eq 'VPNTestL2TP'
      expect(key).to be_l2tp_password

      key = Keychain.find(name: 'VPNTestL2TP', kind: :shared_secret)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_shared_secret_id
      expect(key.name).to eq 'VPNTestL2TP'
      expect(key).to be_shared_secret

      key = Keychain.find(name: 'VPNTestL2TP', kind: :ipsec_password)
      expect(key).to be_nil

      # Overwriting existing VPN

      arguments = 'create -l VPNTestL2TP -e hawaii.example.com -u Carol -p letm3in -g AnotherL2TPGroup -s s3cret --force'
      output, status = Macosvpn.sudo arguments: arguments
      expect(output).to include 'You already have a service VPNTestL2TP'
      expect(output).to include 'Successfully created L2TP over IPSec VPN VPNTestL2TP'
      expect(status).to eq 0

      service = SCUtil::Services.find_by_name('VPNTestL2TP')
      expect(service).to be_present
      expect(service.name).to eq 'VPNTestL2TP'
      expect(service.ipsec_authentication_method).to eq 'SharedSecret'
      expect(service.ipsec_shared_secret_id).to be_present
      expect(service.ipsec_shared_secret_encryption).to eq 'Keychain'
      expect(service.ipsec_local_identifier).to eq 'AnotherL2TPGroup'
      expect(service.ipsec_local_identifier_type).to eq 'KeyID'
      expect(service.ipsec_remote_address).to be nil
      expect(service.ipsec_xauth_name).to be nil
      expect(service.ipsec_xauth_password_encryption).to be nil
      expect(service.ipv4_config_method).to eq 'PPP'
      expect(service.ipv4_override_primary).to eq 1
      expect(service.interface_type).to eq 'PPP'
      expect(service.interface_subtype).to eq 'L2TP'
      expect(service.ppp_auth_name).to eq 'Carol'
      expect(service.ppp_auth_password_id).to be_present
      expect(service.ppp_auth_password_encryption).to eq 'Keychain'
      expect(service.ppp_common_remote_address).to eq 'hawaii.example.com'

      sleep 0.5
      key = Keychain.find(name: 'VPNTestL2TP', kind: :l2tp_password)
      expect(key).to be_present
      expect(key.id).to eq service.ppp_auth_password_id
      expect(key.name).to eq 'VPNTestL2TP'
      expect(key).to be_l2tp_password

      key = Keychain.find(name: 'VPNTestL2TP', kind: :shared_secret)
      expect(key).to be_present
      expect(key.id).to eq service.ipsec_shared_secret_id
      expect(key.name).to eq 'VPNTestL2TP'
      expect(key).to be_shared_secret

      key = Keychain.find(name: 'VPNTestL2TP', kind: :ipsec_password)
      expect(key).to be_nil

      # Removing the Group

      arguments = 'create -l VPNTestL2TP -e newyork.example.com -u Eric -p letm3in2 -s s3cret2 --force'
      output, status = Macosvpn.sudo arguments: arguments
      expect(output).to include 'You already have a service VPNTestL2TP'
      expect(output).to include 'Successfully created L2TP over IPSec VPN VPNTestL2TP'
      expect(status).to eq 0

      service = SCUtil::Services.find_by_name('VPNTestL2TP')
      expect(service).to be_present
      expect(service.name).to eq 'VPNTestL2TP'
      expect(service.ipsec_local_identifier).to be nil
      expect(service.ipsec_local_identifier_type).to be nil
      expect(service.ppp_common_remote_address).to eq 'newyork.example.com'
      expect(service.ppp_auth_name).to eq 'Eric'
    end
  end

end
