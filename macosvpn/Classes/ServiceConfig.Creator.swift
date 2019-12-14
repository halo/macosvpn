/*
 Copyright (c) 2014-2019 halo. https://github.com/halo/macosvpn

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to
 the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import SystemConfiguration

extension ServiceConfig {
  enum Creator {
    /// Creates a macOS VPN network service based on the configuration of the ServiceConfig that was passed in.
    static func create(_ config: ServiceConfig, usingPreferencesRef preferences: SCPreferences) throws {

      let initialTopInterface = try NetworkInterface.Initialize.call(kind: config.kind)

      Log.debug("Instantiating interface references for service `\(config.name)`...")
      guard let service = SCNetworkServiceCreate(preferences, initialTopInterface) else {
        throw ExitError(message: "Could not create network service for \(config.name)",
          code: .networkServiceCreationFailed,
          systemStatus: true)
      }

      Log.debug("Adding default protocols (DNS, etc.) to service `\(config.name)`...")
      guard SCNetworkServiceEstablishDefaultConfiguration(service) else {
        throw ExitError(message: "Could not establish a default service configuration for \(config.name)",
          code: .defaultConfigurationFailed,
          systemStatus: true)
      }

      Log.debug("Assigning name to service `\(config.name)`...")
      guard SCNetworkServiceSetName(service, (config.name as CFString)) else {
        throw ExitError(message: "Could not assign a name to \(config.name)",
          code: .networkServiceNamingFailed,
          systemStatus: true)
      }

      Log.debug("And we also would like to know the internal ID of this service")
      let serviceIDCF = SCNetworkServiceGetServiceID(service)
      Log.debug("Look at my service ID: \(serviceIDCF!)")
      config.serviceID = serviceIDCF as String?




      Log.debug("Reloading top Interface...")
      // Because, if we would like to modify the interface, we first need to freshly fetch it from the service
      // See https://lists.apple.com/archives/macnetworkprog/2013/Apr/msg00016.html
      let topInterfaceOptional = SCNetworkServiceGetInterface(service)

      guard let topInterface = topInterfaceOptional else {
        Log.error("Error: Get the top interface for service \(config.name)")
        throw ExitError(message: "", code: .todo)
      }



      switch config.kind {

      case .L2TPOverIPSec:
        Log.debug("Configuring \(config.humanKind) Service")
        // Let's apply all configuration to the PPP interface
        // Specifically, the servername, account username and password
        guard SCNetworkInterfaceSetConfiguration(topInterface, config.l2TPPPPConfig) else {
          Log.error("Error: Could not configure PPP interface for service \(config.name)")
          throw ExitError(message: "", code: .todo)   //PPPInterfaceConfigurationFailed
        }

        Log.debug("Successfully configured PPP interface of service \(config.name)")
        // Now let's apply the shared secret to the IPSec part of the L2TP/IPSec Interface
        let extendedType: CFString = "IPSec" as CFString
        guard SCNetworkInterfaceSetExtendedConfiguration(topInterface, extendedType, config.l2TPIPSecConfig) else {
          Log.error("Error: Could not configure IPSec on PPP interface for service \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
          throw ExitError(message: "", code: .todo)   //IPSecInterfaceConfigurationFailed
        }
        Log.debug("Successfully configured IPSec on PPP interface for service %\(config.name)")

        break



      case .CiscoIPSec:
        Log.debug("Configuring \(config.humanKind) Service")
        // Let's apply all configuration data to the Cisco IPSec interface
        // As opposed to L2TP, here all configuration goes to the top Interface, i.e. the only Interface there is.
        guard SCNetworkInterfaceSetConfiguration(topInterface, config.ciscoConfig) else {
          Log.error("Error: Could not configure Cisco IPSec interface for service \(config.name)")
          throw ExitError(message: "", code: .todo)   //CiscoInterfaceConfigurationFailed
        }
        Log.debug("Successfully configured Cisco IPSec interface of service \(config.name)")
        break
      }





      Log.debug("Fetching IPv4 protocol of service \(config.name)...")
      guard let serviceProtocol = SCNetworkServiceCopyProtocol(service, kSCNetworkProtocolTypeIPv4) else {
        throw ExitError(message: "Could not fetch IPv4 protocol of \(config.name)",
          code: .todo,
          systemStatus: true)   //CopyingServiceProtocolFailed
      }

      switch config.kind {

      case .L2TPOverIPSec:
        Log.debug("Configuring IPv4 protocol of service \(config.name)...")
        guard SCNetworkProtocolSetConfiguration(serviceProtocol, config.l2TPIPv4Config) else {
          throw ExitError(message: "Could not configure IPv4 L2TP protocol of \(config.name)",
            code: .todo,
            systemStatus: true)   //CopyingServiceProtocolFailed
        }
        break


      case .CiscoIPSec:
        Log.debug("Configuring IPv4 protocol of service \(config.name)...")
        guard SCNetworkProtocolSetConfiguration(serviceProtocol, config.ciscoIPv4Config) else {
          throw ExitError(message: "Could not configure IPv4 Cisco protocol of \(config.name)",
            code: .todo,
            systemStatus: true)   //CopyingServiceProtocolFailed
        }
        break
      }







      let networkSet = try NetworkSet.Current.call(usingPreferencesRef: preferences)

      try NetworkSet.RemoveServices.call(withName: config.name, fromNetworkSet: networkSet)









      Log.debug("Adding Service \(service) to networkSet \(networkSet)...")

      guard SCNetworkSetAddService(networkSet, service) else {
        if SCError() == 1005 {
          Log.warn("Skipping VPN Service \(config.humanKind) because it already exists.")
          throw ExitError(message: "", code: .todo)   //Success
        }
        else {
          Log.error("Error: Could not add new VPN service %@ to current network set. \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
          throw ExitError(message: "", code: .todo)   //AddingNetworkServiceFailed
        }
      }
      Log.debug("Added successfully to networkSet...")




      Log.debug("Preparing to add Keychain items for service \(config.name)...")

      switch config.kind {

      case .L2TPOverIPSec:
        if config.serviceID != nil && config.username != nil && config.password != nil {
          Log.debug("Creating PPP Keychain Item...")

          try Keychain.createPasswordKeyChainItem(config.name,
                                                  forService: config.serviceID!,
                                                  withAccount: config.username!,
                                                  andPassword: config.password!)
        }

        break


      case .CiscoIPSec:
        if config.serviceID != nil && config.password != nil {
          Log.debug("Creating XAuth Keychain Item...")

          try Keychain.createXAuthKeyChainItem(config.name,
                                               forService: config.serviceID!,
                                               withPassword: config.password!)
        }


        break

      }

      if config.serviceID != nil && config.sharedSecret != nil {
        Log.debug("Creating Shared Secret Keychain Item...")

        try Keychain.createSharedSecretKeyChainItem(config.name,
                                                    forService: config.serviceID!,
                                                    withPassword: config.sharedSecret!)

      }









      Log.debug("Commiting all changes including service \(config.name)...")
      if !SCPreferencesCommitChanges(preferences) {
        Log.error("Error: Could not commit preferences with service \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
        throw ExitError(message: "", code: .committingPreferencesFailed)   //CommingingPreferencesFailed
      }
      if !SCPreferencesApplyChanges(preferences) {
        Log.error("Error: Could not apply changes with service \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
        throw ExitError(message: "", code: .applyingPreferencesFailed)   //ApplyingPreferencesFailed
      }

      Log.info("Successfully created \(config.humanKind) VPN \(config.name) with ID \(config.serviceID ?? "nil")")
    }
  }
}
