require 'spec_helper'

RSpec.describe 'Creating a VPN Service' do

  context 'no sudo' do
    it 'warns about the missing permissions' do
      arguments = 'create -c Atlantic -e atlantic.example.com -u Alice -p p4ssw0rd -g EasyVPNGRoup -s s3same'
      output, status = run sudo: false, arguments: arguments
      expect(status).to eq 31
      expect(output).to include 'without superuser privileges'
    end
  end

end
