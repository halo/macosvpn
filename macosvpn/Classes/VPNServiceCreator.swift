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
// Exit status codes: 30-59
public class VPNServiceCreator: NSObject {

  /******************
   * PUBLIC METHODS *
   ******************/

  // This method creates one VPN interface according to the desired configuration
  public class func createService(config: VPNServiceConfig, usingPreferencesRef: SCPreferencesRef) -> Int {

    DDLogDebug("Creating new \(config.humanType) Service using \(config)")

    // These variables will hold references to our new interfaces
    let initialTopInterface: SCNetworkInterfaceRef!
    let initialBottomInterface: SCNetworkInterfaceRef!

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
      return 32
    }

    if initialTopInterface == nil {
      DDLogError("kSCNetworkInterfaceIPv4 = \(kSCNetworkInterfaceIPv4)")
      DDLogError("kSCNetworkInterfaceTypePPP = \(kSCNetworkInterfaceTypePPP)")
      DDLogError("Boom")
      return 998
    }

    DDLogDebug("Instantiating interface references...")
    DDLogDebug("Creating a new, fresh VPN service in memory using the interface we already created")
    guard let service = SCNetworkServiceCreate(usingPreferencesRef, initialTopInterface!) else {
      DDLogError("usingPreferencesRef = \(usingPreferencesRef)")
      DDLogError("topInterface = \(initialTopInterface)")
      DDLogError("Boom")
      return 998
    }

    DDLogDebug("That service is to have a name")
    let success = SCNetworkServiceSetName(service, (config.name as CFString))
    if success {
      DDLogDebug("That went well it got the name \(config.name)")
    } else {
      DDLogDebug("That was problematic")
      return 999
    }
    DDLogDebug("And we also would like to know the internal ID of this service")

    let serviceIDCF = SCNetworkServiceGetServiceID(service)
    DDLogDebug("Look at my service ID: \(serviceIDCF!)")
    config.serviceID = serviceIDCF as String!


    //config.serviceID = SCNetworkServiceGetServiceID(service)
    // Interestingly enough, the interface variables in itself are now worthless.
    // We used them to create the service and that's it, we cannot modify or use them any more.
    DDLogDebug("Deallocating obsolete interface references...")
    //CFRelease(topInterface)

    //topInterface = nil
    //bottomInterface = nil

    DDLogDebug("Reloading top Interface...")
    // Because, if we would like to modify the interface, we first need to freshly fetch it from the service
    // See https://lists.apple.com/archives/macnetworkprog/2013/Apr/msg00016.html
    let topInterface = SCNetworkServiceGetInterface(service)
    // Error Codes 50-59


    switch config.type {
    case VPNServiceType.L2TPOverIPSec:
      DDLogDebug("Configuring \(config.humanType) Service")
      // Let's apply all configuration to the PPP interface
      // Specifically, the servername, account username and password
      if SCNetworkInterfaceSetConfiguration(topInterface!, config.L2TPPPPConfig) {
        DDLogDebug("Successfully configured PPP interface of service \(config.name)")
      }
      else {
        DDLogError("Error: Could not configure PPP interface for service \(config.name)")
        return 50
      }
      // Now let's apply the shared secret to the IPSec part of the L2TP/IPSec Interface
      let thingy:CFString = "IPSec"
      if SCNetworkInterfaceSetExtendedConfiguration(topInterface!, thingy, config.L2TPIPSecConfig) {
        DDLogDebug("Successfully configured IPSec on PPP interface for service %\(config.name)")
      }
      else {
        DDLogError("Error: Could not configure IPSec on PPP interface for service \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
        return 35
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
          return 51
        }
      default:
        DDLogError("Error: I cannot handle this interface type yet.")
        return 59
      }
      
    // Error Codes ...
    DDLogDebug("Adding default protocols (DNS, etc.) to service \(config.name)...")
    if !SCNetworkServiceEstablishDefaultConfiguration(service) {
      DDLogError("Error: Could not establish a default service configuration for \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
      return 36
    }


    DDLogDebug("Fetching set of all available network services...")
    guard let networkSet = SCNetworkSetCopyCurrent(usingPreferencesRef) else {
      DDLogError("Error: Could not fetch current network set when creating \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
      return 37
    }

    /*
    if networkSet != nil {
      DDLogDebug("Yep, here it is: \(networkSet)")
    } else {
    }
*/
    guard let services = SCNetworkSetCopyServices(networkSet) else {
      DDLogError("Could not retrieve network set")
      return 000
    }

    DDLogDebug("Let's see how many services we have in total")

    //let arraySize = CFArrayGetCount(services)
    //DDLogDebug("Ok we have \(arraySize)")

    for serviceInstanceWrapper in services {
      let existingService = serviceInstanceWrapper as! SCNetworkService
      DDLogDebug("existingService = \(existingService)")

   // }

    //for i in 0..<arraySize {
      //DDLogDebug("Looking at no \(i)")

     // let unmanagedObject: UnsafePointer<Void> = CFArrayGetValueAtIndex(services, i)
     // let existingService = unsafeBitCast(unmanagedObject, SCNetworkServiceRef.self)

      //DDLogDebug("existingService = \(existingService)")

      guard let serviceNameCF = SCNetworkServiceGetName(existingService) else {
        DDLogError("SCNetworkServiceGetName failed")
        return 999
      }

      guard let serviceIDCF = SCNetworkServiceGetServiceID(existingService) else {
        DDLogError("SCNetworkServiceGetServiceID failed")
        return 999
      }

      //let serviceNameNS: NSString = serviceNameCF as NSString
      //let serviceName: String = serviceNameNS as String



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
        return 44;
      }

      //SCNetworkServiceRef serviceToDelete = SCNetworkServiceCopy(prefs, (__bridge CFStringRef)(serviceID));
      DDLogInfo("Removing duplicate VPN Service \(config.name) because you specified the --force flag.")

      if SCNetworkServiceRemove(existingService) {
        DDLogDebug("Successfully removed duplicate VPN Service \(config.name).")
      } else {
        DDLogError("Error: Could not remove duplicate VPN service \(config.name) from current network set. \(SCErrorString(SCError())) (Code \(SCError()))")
        return 42
      }

    }


    DDLogDebug("Fetching IPv4 protocol of service \(config.name)...")
    let serviceProtocol = SCNetworkServiceCopyProtocol(service, kSCNetworkProtocolTypeIPv4)
    if serviceProtocol == nil {
      DDLogError("Error: Could not fetch IPv4 protocol of \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
      return 39
    }
    DDLogDebug("Configuring IPv4 protocol of service \(config.name)...")
    if !SCNetworkProtocolSetConfiguration(serviceProtocol!, config.L2TPIPv4Config) {
      DDLogError("Error: Could not configure IPv4 protocol of \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
      return 40
    }


    DDLogDebug("Adding Service \(service) to networkSet \(networkSet)...")

    if SCNetworkSetAddService(networkSet, service) {
      DDLogDebug("Added successfully to networkSet...")
    } else {
      if SCError() == 1005 {
        DDLogWarn("Skipping VPN Service \(config.humanType) because it already exists.")
        return 0
      }
      else {
        DDLogError("Error: Could not add new VPN service %@ to current network set. \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
        return 38
      }
    }



    DDLogDebug("Preparing to add Keychain items for service \(config.name)...")
    if config.password != nil {
      let code = VPNKeychain.createPasswordKeyChainItem(config.name, forService: config.serviceID, withAccount: config.username, andPassword: config.password!)
      if code > 0 {
        DDLogError("Error: Could not createPasswordKeyChainItem. \(config.name). \(code)")
        return 999
      }
    }
    if config.sharedSecret != nil {
      let code = VPNKeychain.createSharedSecretKeyChainItem(config.name, forService: config.serviceID, withPassword: config.sharedSecret)
      if code > 0 {
        DDLogError("Error: Could not createSharedSecretKeyChainItem. \(config.name). \(code)")
        return 999
      }
    }


    DDLogDebug("Commiting all changes including service \(config.name)...")
    if !SCPreferencesCommitChanges(usingPreferencesRef) {
      DDLogError("Error: Could not commit preferences with service. \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
      return 41
    }
    if !SCPreferencesApplyChanges(usingPreferencesRef) {
      DDLogError("Error: Could not apply changes with service. \(config.name). \(SCErrorString(SCError())) (Code \(SCError()))")
      return 42
    }

    DDLogInfo("Successfully created \(config.humanType) VPN \(config.name) with ID \(config.serviceID)")

    return 0
  }
}
