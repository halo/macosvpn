import Darwin
import Moderator

extension ServiceConfig {
  enum Parser {
    /// Converts an Array of command line arguments into one ServiceConfig.
    static func parse(_ arguments: [String]) -> ServiceConfig {
      let parser = Moderator()

      // Both L2TP and Cisco
      let endpoint = parser.add(
        Argument<String?>.optionWithValue(
          Flag.Endpoint.rawValue,
          Flag.EndpointShort.rawValue, name: ""))

      let username = parser.add(
        Argument<String?>.optionWithValue(
          Flag.Username.rawValue,
          Flag.UsernameShort.rawValue, name: ""))

      let password = parser.add(
        Argument<String?>.optionWithValue(
          Flag.Password.rawValue,
          Flag.PasswordShort.rawValue, name: ""))

      let sharedSecret = parser.add(
        Argument<String?>.optionWithValue(
          Flag.SharedSecret.rawValue,
          Flag.SharedSecretShort.rawValue, name: ""))

      let groupName = parser.add(
        Argument<String?>.optionWithValue(
          Flag.GroupName.rawValue,
          Flag.GroupNameShort.rawValue, name: ""))


      // L2TP-specific
      let L2TPName = parser.add(
        Argument<String?>.optionWithValue(
          Flag.L2TP.rawValue,
          Flag.L2TPShort.rawValue, name: ""))

      let splitTunnel = parser.add(
        Argument<Bool>.option(
          Flag.Split.rawValue,
          Flag.SplitShort.rawValue))

      let disconnectOnSwitch = parser.add(
        Argument<Bool>.option(
          Flag.DisconnectSwitch.rawValue,
          Flag.DisconnectSwitchShort.rawValue))

      let disconnectOnLogout = parser.add(
        Argument<Bool>.option(
          Flag.DisconnectLogout.rawValue,
          Flag.DisconnectLogoutShort.rawValue))

      // Cisco-specific
      let ciscoName = parser.add(
        Argument<String?>.optionWithValue(
          Flag.Cisco.rawValue,
          Flag.CiscoShort.rawValue, name: ""))

      // Parse arguments
      do {
        try parser.parse(arguments, strict: false)
      } catch {
        Log.error(String(describing: error))
        exit(VPNExitCode.InvalidArguments)
      }
      
      // Bail out on missing mandatory arguments
      guard !(endpoint.value?.isEmpty ?? true) else {
        Log.error("You did not provide an endpoint")
        exit(VPNExitCode.MissingEndpoint)
      }
      
      // Do not allow unknown arguments
      if !parser.remaining.isEmpty {
        Log.error("Unknown arguments: \(parser.remaining.joined(separator: " "))")
        exit(VPNExitCode.UnknownArguments)
      }
      
      let service: ServiceConfig

      if !(L2TPName.value?.isEmpty ?? true) {
        service = ServiceConfig(kind: .L2TPOverIPSec,
                                name: L2TPName.value!,
                                endpoint: endpoint.value!)

      } else if !(ciscoName.value?.isEmpty ?? true) {
        service = ServiceConfig(kind: .CiscoIPSec,
                                name: ciscoName.value!,
                                endpoint: endpoint.value!)

      } else {
        exit(VPNExitCode.UnknownService)
      }
      
      // Both L2TP and Cisco
      service.username = username.value
      service.password = password.value
      service.sharedSecret = sharedSecret.value
      service.localIdentifier = groupName.value

      // L2TP-specific
      service.enableSplitTunnel = splitTunnel.value
      service.disconnectOnSwitch = disconnectOnSwitch.value
      service.disconnectOnLogout = disconnectOnLogout.value
      
      if endpoint.value?.isEmpty ?? true {
        exit(VPNExitCode.MissingEndpoint)
      }
      service.enableSplitTunnel = splitTunnel.value

      return service
    }
  }
}
