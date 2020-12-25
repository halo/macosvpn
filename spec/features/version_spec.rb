# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Showing Version' do
  context 'with the --version flag' do
    it 'shows the Help' do
      output, status = Macosvpn.call arguments: '--version'
      expect(output).to eq "1.0.3\n"
      expect(status).to eq 2
    end
  end
end
