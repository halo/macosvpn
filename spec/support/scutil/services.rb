# frozen_string_literal: true

module SCUtil
  module Services
    def self.all
      Preferences.new.services
    end

    def self.find_by_name(name)
      all.detect { |service| service.name == name }
    end
  end
end
