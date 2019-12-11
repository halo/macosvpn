import Darwin
import Moderator

extension ServiceConfig {
  enum Parser {
    /// Converts an Array of command line arguments into one ServiceConfig.
    static func parse(_ arguments: [String]) throws -> ServiceConfig {
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

      Log.debug("Parsing arguments for service...")
      // This 3rd party library should not throw, when passed in `strict: false`.
      // If it still does, it's OK to let it bubble up. It will be caught higher up.
      try parser.parse(arguments, strict: false)
      Log.debug("Parsing succeeded, \(parser.remaining.count) arguments unaccounted for.")

      // Do not allow unknown arguments
      guard parser.remaining.isEmpty else {
        throw ExitError(message: "Unknown arguments: \(parser.remaining.joined(separator: " "))",
                        code: .invalidServiceConfigArgumentsDetected)
      }
      Log.debug("You did not pass in any invalid arguments")

      // Bail out on missing mandatory arguments
      guard !(endpoint.value?.isEmpty ?? true) else {
        throw ExitError(message: "You did not provide an endpoint such as `\(Flag.Endpoint.dashed) example.com`",
                        code: .missingEndpoint)
      }

      let service: ServiceConfig

      if !(L2TPName.value?.isEmpty ?? true) {
        Log.debug("Converting arguments to L2TP ServiceConfig...")
        service = ServiceConfig(kind: .L2TPOverIPSec,
                                name: L2TPName.value!,
                                endpoint: endpoint.value!)

      } else if !(ciscoName.value?.isEmpty ?? true) {
        Log.debug("Converting arguments to Cisco ServiceConfig...")
        service = ServiceConfig(kind: .CiscoIPSec,
                                name: ciscoName.value!,
                                endpoint: endpoint.value!)

      } else {
        throw ExitError(message: "Unknown Service provided, there is only \(Flag.L2TP.dashed) and \(Flag.Cisco.rawValue)",
                        code: .invalidServiceKindDetected)
      }
      Log.debug("Conversion succeeded.")

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
        throw ExitError(message: "", code: .todo)
      }
      service.enableSplitTunnel = splitTunnel.value

      return service
    }
  }
}
