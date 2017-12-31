# frozen_string_literal: true

module SCUtil
  class Preferences
    def services
      result = []
      services_data.each do |id, attributes|
        attributes['id'] = id
        result << Service.new(attributes)
      end
      result
    end

    private

    # This is a more basic approach to `scutil --nc show MyVPNService`
    def plist
      Plist.parse_xml('/Library/Preferences/SystemConfiguration/preferences.plist')
    end

    def services_data
      plist['NetworkServices']
    end
  end
end
