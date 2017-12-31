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
open class VPNServiceRemover {

  /******************
   * PUBLIC METHODS *
   ******************/

  // This method creates one VPN interface according to the desired configuration
  open class func removeService(_ name: String, usingPreferencesRef: SCPreferences) -> Int32 {

    DDLogDebug("Removing Service \(name)")

    DDLogDebug("Fetching set of all available network services...")
    guard let networkSet = SCNetworkSetCopyCurrent(usingPreferencesRef) else {
      DDLogError("Error: Could not fetch current network set when removing \(name). \(SCErrorString(SCError())) (Code \(SCError()))")
      return VPNExitCode.CopyingCurrentNetworkSetFailed
    }

    guard let services = SCNetworkSetCopyServices(networkSet) else {
      DDLogError("Could not retrieve network services set")
      return VPNExitCode.CopyingNetworkServicesFailed
    }

    var deletedCount: Int = 0
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

      if name != serviceName {
        DDLogDebug("Ignoring existing Service \(serviceName)")
        continue
      }

      DDLogDebug("That Service has the ID \(serviceID)")

      if SCNetworkServiceRemove(existingService) {
        DDLogInfo("Successfully deleted VPN Service \(name)")
        deletedCount += 1;
      } else {
        DDLogError("Error: Could not remove VPN service \(name) from current network set. \(SCErrorString(SCError())) (Code \(SCError()))")
        return VPNExitCode.RemovingServiceFailed
      }
    }

    if (deletedCount == 0) {
      DDLogError("No VPN Service was deleted. Are you sure it exists?")
      return VPNExitCode.NoServicesRemoved
    }

    DDLogDebug("Commiting all changes including service \(name)...")
    if !SCPreferencesCommitChanges(usingPreferencesRef) {
      DDLogError("Sorry, without superuser privileges I won't be able to remove any VPN interfaces.");
      DDLogDebug("Error: Could not commit preferences after removing service \(name). \(SCErrorString(SCError())) (Code \(SCError()))")
      return VPNExitCode.CommingingPreferencesFailed
    }
    if !SCPreferencesApplyChanges(usingPreferencesRef) {
      DDLogError("Error: Could not apply changes after removing \(name). \(SCErrorString(SCError())) (Code \(SCError()))")
      return VPNExitCode.ApplyingPreferencesFailed
    }

    return VPNExitCode.Success
  }
}
