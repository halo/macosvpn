# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Showing Help' do
  context 'no arguments' do
    it 'shows the Help' do
      output, status = Macosvpn.call arguments: nil
      expect(status).to eq 82
      expect(output).to include 'You must specify a command'
    end
  end

  context 'only the --help flag' do
    it 'shows the Help' do
      output, status = Macosvpn.call arguments: '--help'
      expect(status).to eq 3
      expect(output).to include 'Usage:'
      expect(output).to include 'sudo macosvpn'
      expect(output).to include 'https://github.com/halo/macosvpn'
    end
  end

  context 'some command including the --help flag' do
    it 'shows the Help' do
      output, status = Macosvpn.call arguments: 'create --cisco Iceland --help'
      expect(status).to eq 3
      expect(output).to include 'Usage:'
      expect(output).to include 'sudo macosvpn'
      expect(output).to include 'https://github.com/halo/macosvpn'
    end
  end
end
