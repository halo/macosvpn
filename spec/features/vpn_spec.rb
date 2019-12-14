# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Creating a VPN Service' do
  context 'no sudo' do
    it 'warns about the missing permissions' do
      arguments = 'create -c Atlantis -e atlantic.example.com -u Alice -p p4ssw0rd -g EasyVPNGroup -s s3same'
      output, status = Macosvpn.call arguments: arguments
      expect(output).to include 'without superuser privileges'
      expect(output).to include 'thus cannot create'
      expect(status).to eq 20
    end
  end
end
