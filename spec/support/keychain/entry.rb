# frozen_string_literal: true

module Keychain
  class Entry
    def initialize(name:, kind:)
      @search_name = name
      @kind = kind
    end

    def exists?
      dump.present?
    end

    def id
      return unless dump

      dump.match(/"svce"<blob>="?([^"]*)/)[1]
    end

    def name
      return unless dump

      dump.match(/0x00000007 <blob>="([^"]*)/)[1]
    end

    def ipsec_password?
      description == 'IPSec XAuth Password'
    end

    def l2tp_password?
      description == 'VPN Password'
    end

    def shared_secret?
      description == 'IPSec Shared Secret'
    end

    private

    attr_reader :search_name

    def kind_argument
      case @kind
      when :ipsec_password then "-D 'IPSec XAuth Password'"
      when :l2tp_password  then "-D 'VPN Password'"
      when :shared_secret  then "-D 'IPSec Shared Secret'"
      when :any            then nil
      else                 raise NotImplementedError
      end
    end

    def description
      return unless dump

      dump.match(/"desc"<blob>="([^"]*)/)[1]
    end

    def dump
      @dump ||= dump!
    end

    def dump!
      _, stdout, _, thread = Open3.popen3(dump_command)
      return unless thread.value.exitstatus.zero?

      stdout.read
    end

    def dump_command
      command = "security find-generic-password -l '#{search_name}' #{kind_argument} /Library/Keychains/System.keychain"
      puts command if ENV['VERBOSE']
      command
    end
  end
end
