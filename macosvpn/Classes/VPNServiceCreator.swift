/*
 Copyright (c) 2015 halo. https://github.com/halo/macosvpn

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

// Vendor dependencies
import SystemConfiguration

// This is were the magic happens.
open class VPNServiceCreator: NSObject {

  /******************
   * PUBLIC METHODS *
   ******************/

  // This method creates one VPN interface according to the desired configuration
  open class func createService(_ config: VPNServiceConfig, usingPreferencesRef: SCPreferences) -> Int32 {

    Log.debug("Creating new \(config.humanType ?? "nil") Service using \(config)")

    // These variables will hold references to our new interfaces
    let initialTopInterface: SCNetworkInterface!
    let initialBottomInterface: SCNetworkInterface!

    switch config.kind {

    case .L2TPOverIPSec:
      Log.debug("L2TP Service detected...")
      // L2TP on top of IPv4
      initialBottomInterface = SCNetworkInterfaceCreateWithInterface(kSCNetworkInterfaceIPv4, kSCNetworkInterfaceTypeL2TP)
      // PPP on top of L2TP
      initialTopInterface = SCNetworkInterfaceCreateWithInterface(initialBottomInterface!, kSCNetworkInterfaceTypePPP)

    case .CiscoIPSec:
      Log.debug("Cisco IPSec Service detected...")
      // Cisco IPSec (without underlying interface)
      initialTopInterface = SCNetworkInterfaceCreateWithInterface(kSCNetworkInterfaceIPv4, kSCNetworkInterfaceTypeIPSec)

    default:
      Log.error("Sorry, this service type is not yet supported")
      return VPNExitCode.UnsupportedInterfaceType
    }

    if initialTopInterface == nil {
      Log.error("kSCNetworkInterfaceIPv4 = \(kSCNetworkInterfaceIPv4)")
      Log.error("kSCNetworkInterfaceTypePPP = \(kSCNetworkInterfaceTypePPP)")
      return VPNExitCode.InterfaceInitializationFailed
    }

    Log.debug("Instantiating interface references...")
    Log.debug("Creating a new, fresh VPN service in memory using the interface we already created")
    guard let service = SCNetworkServiceCreate(usingPreferencesRef, initialTopInterface!) else {
      Log.error("usingPreferencesRef = \(usingPreferencesRef)")
      Log.error("topInterface = \(String(describing: initialTopInterface))")
      return VPNExitCode.NetworkServiceCreationFailed
    }

    Log.debug("That service is to have a name")
    // FIXME This unwrap can break
    let success = SCNetworkServiceSetName(service, (config.name as CFString))
    if success {
      Log.debug("That went well it got the name \(config.name ?? "nil")")
    } else {
      Log.debug("That was problematic")
      return VPNExitCode.NetworkServiceNamingFailed
    }
    Log.debug("And we also would like to know the internal ID of this service")

    let serviceIDCF = SCNetworkServiceGetServiceID(service)
    Log.debug("Look at my service ID: \(serviceIDCF!)")
    config.serviceID = serviceIDCF as String?


    Log.debug("Reloading top Interface...")
    // Because, if we would like to modify the interface, we first need to freshly fetch it from the service
    // See https://lists.apple.com/archives/macnetworkprog/2013/Apr/msg00016.html
    let topInterface = SCNetworkServiceGetInterface(service)

    switch config.kind {

    case .L2TPOverIPSec:
      Log.debug("Configuring \(config.humanType ?? "nil") Service")
      // Let's apply all configuration to the PPP interface
      // Specifically, the servername, account username and password
      if SCNetworkInterfaceSetConfiguration(topInterface!, config.l2TPPPPConfig) {
        Log.debug("Successfully configured PPP interface of service \(config.name ?? "nil")")
      }
      else {
        Log.error("Error: Could not configure PPP interface for service \(config.name ?? "nil")")
        return VPNExitCode.PPPInterfaceConfigurationFailed
      }
      // Now let's apply the shared secret to the IPSec part of the L2TP/IPSec Interface
      let thingy:CFString = "IPSec" as CFString
      if SCNetworkInterfaceSetExtendedConfiguration(topInterface!, thingy, config.l2TPIPSecConfig) {
        Log.debug("Successfully configured IPSec on PPP interface for service %\(config.name ?? "nil")")
      }
      else {
        Log.error("Error: Could not configure IPSec on PPP interface for service \(config.name ?? "nil"). \(SCErrorString(SCError())) (Code \(SCError()))")
        return VPNExitCode.IPSecInterfaceConfigurationFailed
      }
      break

    case .CiscoIPSec:
      Log.debug("Configuring \(config.humanType ?? "nil") Service")
      // Let's apply all configuration data to the Cisco IPSec interface
      // As opposed to L2TP, here all configuration goes to the top Interface, i.e. the only Interface there is.
      if SCNetworkInterfaceSetConfiguration(topInterface!, config.ciscoConfig) {
        Log.debug("Successfully configured Cisco IPSec interface of service \(config.name ?? "nil")")
      }
      else {
        Log.error("Error: Could not configure Cisco IPSec interface for service \(config.name ?? "nil")")
        return VPNExitCode.CiscoInterfaceConfigurationFailed
      }
      break

    default:
      Log.error("Error: I cannot handle this interface type yet.")
      return VPNExitCode.CreatorDoesNotSupportInterfaceType
    }

    Log.debug("Adding default protocols (DNS, etc.) to service \(config.name ?? "nil")...")
    if !SCNetworkServiceEstablishDefaultConfiguration(service) {
      Log.error("Error: Could not establish a default service configuration for \(config.name ?? "nil"). \(SCErrorString(SCError())) (Code \(SCError()))")
      return VPNExitCode.DefaultConfigurationFailed
    }

    Log.debug("Fetching set of all available network services...")
    guard let networkSet = SCNetworkSetCopyCurrent(usingPreferencesRef) else {
      Log.error("Error: Could not fetch current network set when creating \(config.name ?? "nil"). \(SCErrorString(SCError())) (Code \(SCError()))")
      return VPNExitCode.CopyingCurrentNetworkSetFailed
    }

    guard let services = SCNetworkSetCopyServices(networkSet) else {
      Log.error("Could not retrieve network services set")
      return VPNExitCode.CopyingNetworkServicesFailed
    }

    for serviceInstanceWrapper in services {
      let existingService = serviceInstanceWrapper as! SCNetworkService
      Log.debug("existingService = \(existingService)")

      guard let serviceNameCF = SCNetworkServiceGetName(existingService) else {
        Log.error("SCNetworkServiceGetName failed")
        return VPNExitCode.GettingServiceNameFailed
      }

      guard let serviceIDCF = SCNetworkServiceGetServiceID(existingService) else {
        Log.error("SCNetworkServiceGetServiceID failed")
        return VPNExitCode.GettingServiceIDFailed
      }

      let serviceName = serviceNameCF as String
      Log.debug("serviceName = \(serviceName)")

      let serviceID = serviceIDCF as String
      Log.debug("serviceID = \(serviceID)")

      if config.name != serviceName {
        Log.debug("Ignoring existing Service \(serviceName)")
        continue
      }

      Log.warn("You already have a service \(config.name ?? "nil") defined.")
      Log.debug("That Service has the ID \(serviceID)")

      if !Arguments.options.forceRequested {
        Log.warn("If you want me to overwrite it, you need to specify the --force flag");
        return VPNExitCode.RefusingToOverwriteExistingService;
      }

      //SCNetworkServiceRef serviceToDelete = SCNetworkServiceCopy(prefs, (__bridge CFStringRef)(serviceID));
      Log.info("Removing duplicate VPN Service \(config.name ?? "nil") because you specified the --force flag.")

      if SCNetworkServiceRemove(existingService) {
        Log.debug("Successfully removed duplicate VPN Service \(config.name ?? "nil").")
      } else {
        Log.error("Error: Could not remove duplicate VPN service \(config.name ?? "nil") from current network set. \(SCErrorString(SCError())) (Code \(SCError()))")
        return VPNExitCode.RemovingDuplicateServiceFailed
      }
    }

    Log.debug("Fetching IPv4 protocol of service \(config.name ?? "nil")...")
    let serviceProtocol = SCNetworkServiceCopyProtocol(service, kSCNetworkProtocolTypeIPv4)
    if serviceProtocol == nil {
      Log.error("Error: Could not fetch IPv4 protocol of \(config.name ?? "nil"). \(SCErrorString(SCError())) (Code \(SCError()))")
      return VPNExitCode.CopyingServiceProtocolFailed
    }
    Log.debug("Configuring IPv4 protocol of service \(config.name ?? "nil")...")
    if !SCNetworkProtocolSetConfiguration(serviceProtocol!, config.l2TPIPv4Config) {
      Log.error("Error: Could not configure IPv4 protocol of \(config.name ?? "nil"). \(SCErrorString(SCError())) (Code \(SCError()))")
      return VPNExitCode.SettingNetworkProtocolConfigFailed
    }

    Log.debug("Adding Service \(service) to networkSet \(networkSet)...")

    if SCNetworkSetAddService(networkSet, service) {
      Log.debug("Added successfully to networkSet...")
    } else {
      if SCError() == 1005 {
        Log.warn("Skipping VPN Service \(config.humanType ?? "nil") because it already exists.")
        return VPNExitCode.Success
      }
      else {
        Log.error("Error: Could not add new VPN service %@ to current network set. \(config.name ?? "nil"). \(SCErrorString(SCError())) (Code \(SCError()))")
        return VPNExitCode.AddingNetworkServiceFailed
      }
    }

    Log.debug("Preparing to add Keychain items for service \(config.name ?? "nil")...")


    if config.password != nil {
      let code = Keychain.createPasswordKeyChainItem(config.name, forService: config.serviceID!, withAccount: config.username!, andPassword: config.password!)
      if code > 0 {
        Log.error("Error: Could not createPasswordKeyChainItem. \(config.name ?? "nil"). \(code)")
        return VPNExitCode.CreatingPasswordKeychainItemFailed
      }
    }
    if config.sharedSecret != nil {
      let code = Keychain.createSharedSecretKeyChainItem(config.name, forService: config.serviceID!, withPassword: config.sharedSecret!)
      if code > 0 {
        Log.error("Error: Could not createSharedSecretKeyChainItem. \(config.name ?? "nil"). \(code)")
        return VPNExitCode.CreatingSharedSecretKeychainItemFailed
      }
    }

    Log.debug("Commiting all changes including service \(config.name ?? "nil")...")
    if !SCPreferencesCommitChanges(usingPreferencesRef) {
      Log.error("Error: Could not commit preferences with service \(config.name ?? "nil"). \(SCErrorString(SCError())) (Code \(SCError()))")
      return VPNExitCode.CommingingPreferencesFailed
    }
    if !SCPreferencesApplyChanges(usingPreferencesRef) {
      Log.error("Error: Could not apply changes with service \(config.name ?? "nil"). \(SCErrorString(SCError())) (Code \(SCError()))")
      return VPNExitCode.ApplyingPreferencesFailed
    }

    Log.info("Successfully created \(config.humanType ?? "nil") VPN \(config.name ?? "nil") with ID \(config.serviceID ?? "nil")")

    return VPNExitCode.Success
  }
}
