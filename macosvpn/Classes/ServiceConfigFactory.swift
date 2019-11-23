import Foundation
import Moderator

extension VPNServiceConfig {
  enum Factory {
    static func make(from arguments: [String]) -> VPNServiceConfig {
      let parser = Moderator()

      // Both L2TP and Cisco
      let endpoint = parser.add(Argument<String?>.optionWithValue("endpoint", "e", name: "", description: ""))
      let username = parser.add(Argument<String?>.optionWithValue("username", "u", name: "", description: ""))
      let password = parser.add(Argument<String?>.optionWithValue("password", "p", name: "", description: ""))
      let sharedSecret = parser.add(Argument<String?>.optionWithValue("sharedsecret", "s", name: "THENAME", description: "THEDESC"))
      let groupName = parser.add(Argument<String?>.optionWithValue("groupname", "g", name: "", description: ""))

      // L2TP-specific
      let L2TPName = parser.add(Argument<String?>.optionWithValue("l2tp", "l", name: "", description: ""))
      let splitTunnel = parser.add(Argument<Bool>.option("split", "x"))
      let disconnectOnSwitch = parser.add(Argument<Bool>.option("disconnectswitch", "i"))
      let disconnectOnLogout = parser.add(Argument<Bool>.option("disconnectlogout", "t"))

      // Cisco-specific
      let ciscoName = parser.add(Argument<String?>.optionWithValue("cisco", "c", name: "", description: ""))

      // Parse arguments
      do {
        try parser.parse(arguments, strict: false)
      } catch {
        Log.error(String(describing: error))
        exit(VPNExitCode.InvalidArguments)
      }
      
      // Bail out on missing mandatory arguments
      guard !(endpoint.value?.isEmpty ?? true) else {
        exit(VPNExitCode.MissingEndpoint)
      }
      
      // Do not allow unknown arguments
      if !parser.remaining.isEmpty {
        Log.error("Unknown arguments: \(parser.remaining.joined(separator: " "))")
        exit(VPNExitCode.UnknownArguments)
      }
      
      let service = VPNServiceConfig()
      
      if !(L2TPName.value?.isEmpty ?? true) {
        service.kind = .L2TP
        service.name = L2TPName.value
      } else if !(ciscoName.value?.isEmpty ?? true) {
        service.kind = .Cisco
        service.name = ciscoName.value
      } else {
        exit(VPNExitCode.UnknownService)
      }
      
      // Both L2TP and Cisco
      service.endpoint = endpoint.value
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
