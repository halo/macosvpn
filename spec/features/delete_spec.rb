# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Deleting a VPN Service' do
  context 'no arguments' do
    it 'fails and is informational' do
      output, status = Macosvpn.sudo arguments: 'delete'
      expect(output).to include ' at least one --name'
      expect(status).to eq 23
    end
  end
end
