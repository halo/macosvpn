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

    DDLogDebug("Creating new \(config.humanType) Service using \(config)")

    // These variables will hold references to our new interfaces
    let initialTopInterface: SCNetworkInterface!
    let initialBottomInterface: SCNetworkInterface!

    switch config.type {

    case VPNServiceType.L2TPOverIPSec:
      DDLogDebug("L2TP Service detected...")
      // L2TP on top of IPv4
      initialBottomInterface = SCNetworkInterfaceCreateWithInterface(kSCNetworkInterfaceIPv4, kSCNetworkInterfaceTypeL2TP)
      // PPP on top of L2TP
      initialTopInterface = SCNetworkInterfaceCreateWithInterface(initialBottomInterface!, kSCNetworkInterfaceTypePPP)

    case VPNServiceType.CiscoIPSec:
      DDLogDebug("Cisco IPSec Service detected...")
      // Cisco IPSec (without underlying interface)
      initialTopInterface = SCNetworkInterfaceCreateWithInterface(kSCNetworkInterfaceIPv4, kSCNetworkInterfaceTypeIPSec)

    default:
      DDLogError("Sorry, this service type is not yet supported")
      return VPNExitCode.UnsupportedInterfaceType
    }

    if initialTopInterface == nil {
      DDLogError("kSCNetworkInterfaceIPv4 = \(kSCNetworkInterfaceIPv4)")
      DDLogError("kSCNetworkInterfaceTypePPP = \(kSCNetworkInterfaceTypePPP)")
      return VPNExitCode.InterfaceInitializationFailed
    }

    DDLogDebug("Instantiating interface references...")
    DDLogDebug("Creating a new, fresh VPN service in memory using the interface we already created")
    guard let service = SCNetworkServiceCreate(usingPreferencesRef, initialTopInterface!) else {
      DDLogError("usingPreferencesRef = \(usingPreferencesRef)")
      DDLogError("topInterface = \(initialTopInterface)")
      return VPNExitCode.NetworkServiceCreationFailed
    }

    DDLogDebug("That service is to have a name")
    let success = SCNetworkServiceSetName(service, (config.name as CFString))
    if success {
      DDLogDebug("That went well it got the name \(config.name)")
    } else {
      DDLogDebug("That was problematic")
      return VPNExitCode.NetworkServiceNamingFailed
    }
    DDLogDebug("And we also would like to know the internal ID of this service")

    let serviceIDCF = SCNetworkServiceGetServiceID(service)
    DDLogDebug("Look at my service ID: \(serviceIDCF!)")
    config.serviceID = serviceIDCF as String!


    DDLogDebug("Reloading top Interface...")
    // Because, if we would like to modify the interface, we first need to freshly fetch it from the service
    // See https://lists.apple.com/archives/macnetworkprog/2013/Apr/msg00016.html
    let topInterface = SCNetworkServiceGetInterface(service)

    switch config.type {

    case VPNServiceType.L2TPOverIPSec:
      DDLogDebug("Configuring \(config.humanType) Service")
      // Let's apply all configuration to the PPP interface
      // Specifically, the servername, account username and password
      if SCNetworkInterfaceSetConfiguration(topInterface!, config.l2TPPPPConfig) {
        DDLogDebug("Successfully configured PPP interface of service \(config.name)")
      }
      else {
        DDLogError("Error: Could not configure PPP interface for service \(config.name)")
        return VPNExitCode.PPPInterfaceConfigurationFailed
      }
      // Now let's apply the shared secret to the IPSec part of the L2TP/IPSec Interface
      let thingy:CFString = "IPSec" as CFString
      if SCNetworkInterfaceSetExtendedConfiguration(topInterface!, thingy, config.l2TPIPSecConfig) {
        DDLogDebug("Successfully configured IPSec on PPP interface for service %\(config.name)")
      }
      else {
        DDLogError("Error: Could not configure IPSec on PPP interface for service \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
        return VPNExitCode.IPSecInterfaceConfigurationFailed
      }
      break

    case VPNServiceType.CiscoIPSec:
      DDLogDebug("Configuring \(config.humanType) Service")
      // Let's apply all configuration data to the Cisco IPSec interface
      // As opposed to L2TP, here all configuration goes to the top Interface, i.e. the only Interface there is.
      if SCNetworkInterfaceSetConfiguration(topInterface!, config.ciscoConfig) {
        DDLogDebug("Successfully configured Cisco IPSec interface of service \(config.name)")
      }
      else {
        DDLogError("Error: Could not configure Cisco IPSec interface for service \(config.name)")
        return VPNExitCode.CiscoInterfaceConfigurationFailed
      }
      break

    default:
      DDLogError("Error: I cannot handle this interface type yet.")
      return VPNExitCode.CreatorDoesNotSupportInterfaceType
    }

    DDLogDebug("Adding default protocols (DNS, etc.) to service \(config.name)...")
    if !SCNetworkServiceEstablishDefaultConfiguration(service) {
      DDLogError("Error: Could not establish a default service configuration for \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
      return VPNExitCode.DefaultConfigurationFailed
    }

    DDLogDebug("Fetching set of all available network services...")
    guard let networkSet = SCNetworkSetCopyCurrent(usingPreferencesRef) else {
      DDLogError("Error: Could not fetch current network set when creating \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
      return VPNExitCode.CopyingCurrentNetworkSetFailed
    }

    guard let services = SCNetworkSetCopyServices(networkSet) else {
      DDLogError("Could not retrieve network services set")
      return VPNExitCode.CopyingNetworkServicesFailed
    }

    for serviceInstanceWrapper in services {
      let existingService = serviceInstanceWrapper as! SCNetworkService
      DDLogDebug("existingService = \(existingService)")

      guard let serviceNameCF = SCNetworkServiceGetName(existingService) else {
        DDLogError("SCNetworkServiceGetName failed")
        return VPNExitCode.GettingServiceNameFailed
      }

      guard let serviceIDCF = SCNetworkServiceGetServiceID(existingService) else {
        DDLogError("SCNetworkServiceGetServiceID failed")
        return VPNExitCode.GettingServiceIDFailed
      }

      let serviceName = serviceNameCF as String
      DDLogDebug("serviceName = \(serviceName)")

      let serviceID = serviceIDCF as String
      DDLogDebug("serviceID = \(serviceID)")

      if config.name != serviceName {
        DDLogDebug("Ignoring existing Service \(serviceName)")
        continue
      }

      DDLogWarn("You already have a service \(config.name) defined.")
      DDLogDebug("That Service has the ID \(serviceID)")

      if !VPNArguments.forceRequested() {
        DDLogWarn("If you want me to overwrite it, you need to specify the --force flag");
        return VPNExitCode.RefusingToOverwriteExistingService;
      }

      //SCNetworkServiceRef serviceToDelete = SCNetworkServiceCopy(prefs, (__bridge CFStringRef)(serviceID));
      DDLogInfo("Removing duplicate VPN Service \(config.name) because you specified the --force flag.")

      if SCNetworkServiceRemove(existingService) {
        DDLogDebug("Successfully removed duplicate VPN Service \(config.name).")
      } else {
        DDLogError("Error: Could not remove duplicate VPN service \(config.name) from current network set. \(SCErrorString(SCError())) (Code \(SCError()))")
        return VPNExitCode.RemovingDuplicateServiceFailed
      }
    }

    DDLogDebug("Fetching IPv4 protocol of service \(config.name)...")
    let serviceProtocol = SCNetworkServiceCopyProtocol(service, kSCNetworkProtocolTypeIPv4)
    if serviceProtocol == nil {
      DDLogError("Error: Could not fetch IPv4 protocol of \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
      return VPNExitCode.CopyingServiceProtocolFailed
    }
    DDLogDebug("Configuring IPv4 protocol of service \(config.name)...")
    if !SCNetworkProtocolSetConfiguration(serviceProtocol!, config.l2TPIPv4Config) {
      DDLogError("Error: Could not configure IPv4 protocol of \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
      return VPNExitCode.SettingNetworkProtocolConfigFailed
    }

    DDLogDebug("Adding Service \(service) to networkSet \(networkSet)...")

    if SCNetworkSetAddService(networkSet, service) {
      DDLogDebug("Added successfully to networkSet...")
    } else {
      if SCError() == 1005 {
        DDLogWarn("Skipping VPN Service \(config.humanType) because it already exists.")
        return VPNExitCode.Success
      }
      else {
        DDLogError("Error: Could not add new VPN service %@ to current network set. \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
        return VPNExitCode.AddingNetworkServiceFailed
      }
    }

    DDLogDebug("Preparing to add Keychain items for service \(config.name)...")
    if config.password != nil {
      let code = VPNKeychain.createPasswordKeyChainItem(config.name, forService: config.serviceID, withAccount: config.username, andPassword: config.password!)
      if code > 0 {
        DDLogError("Error: Could not createPasswordKeyChainItem. \(config.name). \(code)")
        return VPNExitCode.CreatingPasswordKeychainItemFailed
      }
    }
    if config.sharedSecret != nil {
      let code = VPNKeychain.createSharedSecretKeyChainItem(config.name, forService: config.serviceID, withPassword: config.sharedSecret)
      if code > 0 {
        DDLogError("Error: Could not createSharedSecretKeyChainItem. \(config.name). \(code)")
        return VPNExitCode.CreatingSharedSecretKeychainItemFailed
      }
    }

    DDLogDebug("Commiting all changes including service \(config.name)...")
    if !SCPreferencesCommitChanges(usingPreferencesRef) {
      DDLogError("Error: Could not commit preferences with service. \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
      return VPNExitCode.CommingingPreferencesFailed
    }
    if !SCPreferencesApplyChanges(usingPreferencesRef) {
      DDLogError("Error: Could not apply changes with service. \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
      return VPNExitCode.ApplyingPreferencesFailed
    }

    DDLogInfo("Successfully created \(config.humanType) VPN \(config.name) with ID \(config.serviceID)")

    return VPNExitCode.Success
  }
}
