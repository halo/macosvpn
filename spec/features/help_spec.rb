require 'spec_helper'

RSpec.describe 'Showing Help' do

  context 'with the --help flag' do
    it 'shows the Help' do
      output, status = run sudo: false, arguments: '--help'
      expect(status).to eq 99
      expect(output).to include 'Usage:'
      expect(output).to include 'sudo macosvpn'
      expect(output).to include 'https://github.com/halo/macosvpn'
    end
  end

end
