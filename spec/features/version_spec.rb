require 'spec_helper'

RSpec.describe 'Showing Version' do

  context 'with the --version flag' do
    it 'shows the Help' do
      output, status = Macosvpn.call arguments: '--version'
      expect(output).to eq "0.3.0\n"
      expect(status).to eq 98
    end
  end

end
