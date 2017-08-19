module SCUtil
  class Service

    def initialize(attributes)
      @attributes = attributes
    end

    def name
      attributes['UserDefinedName']
    end

    def ipsec_authentication_method
      ipsec['AuthenticationMethod']
    end

    def ipsec_local_identifier
      ipsec['LocalIdentifier']
    end

    def ipsec_local_identifier_type
      ipsec['LocalIdentifierType']
    end

    def ipsec_remote_address
      ipsec['RemoteAddress']
    end

    def ipsec_shared_secret_id
      ipsec['SharedSecret']
    end

    def ipsec_shared_secret_encryption
      ipsec['SharedSecretEncryption']
    end

    def ipsec_xauth_name
      ipsec['XAuthName']
    end

    def ipsec_xauth_password_id
      ipsec['XAuthPassword']
    end

    def ipsec_xauth_password_encryption
      ipsec['XAuthPasswordEncryption']
    end

    def ipv4_config_method
      ipv4['ConfigMethod']
    end

    def ipv4_override_primary
      ipv4['OverridePrimary']
    end

    def interface_type
      interface['Type']
    end

    def interface_subtype
      interface['SubType']
    end

    def ppp_auth_name
      attributes.fetch('PPP', {})['AuthName']
    end

    def ppp_auth_password_id
      attributes.fetch('PPP', {})['AuthPassword']
    end

    def ppp_auth_password_encryption
      attributes.fetch('PPP', {})['AuthPasswordEncryption']
    end

    def ppp_common_remote_address
      attributes.fetch('PPP', {})['CommRemoteAddress']
    end

    def ppp_disconnect_on_fast_user_switch
      attributes.fetch('PPP', {})['DisconnectOnFastUserSwitch']
    end

    def ppp_disconnect_on_logout
      attributes.fetch('PPP', {})['DisconnectOnLogout']
    end

    private

    attr_reader :attributes

    def ipsec
      attributes.fetch('IPSec', {})
    end

    def ipv4
      attributes.fetch('IPv4', {})
    end

    def interface
      attributes.fetch('Interface', {})
    end

  end
end
