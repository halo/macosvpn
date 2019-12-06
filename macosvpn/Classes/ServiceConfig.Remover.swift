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

extension ServiceConfig {
  enum Remover {
    static func delete(names: [String], all: Bool, usingPreferencesRef: SCPreferences) -> Int32 {

      if all {
        Log.debug("Removing all L2TP and Cisco Services")
      } else {
        Log.debug("Removing Services \(names)")
      }

      Log.debug("Fetching set of all available network services...")
      guard let networkSet = SCNetworkSetCopyCurrent(usingPreferencesRef) else {
        Log.error("Error: Could not fetch current network set. \(SCErrorString(SCError())) (Code \(SCError()))")
        return ExitCode.CopyingCurrentNetworkSetFailed
      }

      guard let services = SCNetworkSetCopyServices(networkSet) else {
        Log.error("Could not retrieve network services set")
        return ExitCode.CopyingNetworkServicesFailed
      }

      var deletedCount: Int = 0
      for serviceInstanceWrapper in services {
        let existingService = serviceInstanceWrapper as! SCNetworkService
        //Log.debug("existingService = \(existingService)")

        guard let serviceName = SCNetworkServiceGetName(existingService) else {
          Log.error("SCNetworkServiceGetName failed")
          return ExitCode.GettingServiceNameFailed
        }

        guard let serviceID = SCNetworkServiceGetServiceID(existingService) else {
          Log.error("SCNetworkServiceGetServiceID failed")
          return ExitCode.GettingServiceIDFailed
        }

        guard let serviceInterface = SCNetworkServiceGetInterface(existingService) else {
          Log.error("SCNetworkServiceGetInterface failed")
          return 999
        }

        guard let interfaceType = SCNetworkInterfaceGetInterfaceType(serviceInterface) else {
          Log.error("SCNetworkServiceGetInterface failed")
          return 999
        }

        if interfaceType != kSCNetworkInterfaceTypePPP && interfaceType != kSCNetworkInterfaceTypeIPSec {
          Log.debug("Ignoring Service \(serviceName) (\(interfaceType))")
          continue
        }


        //Log.debug("serviceInterface = \(serviceInterface)")


        if interfaceType == kSCNetworkInterfaceTypePPP {

          guard let bottomInterface = SCNetworkInterfaceGetInterface(serviceInterface) else {
            Log.error("Could not get bottom interface of PPP service")
            return 999
          }
          //Log.debug("bottomInterface = \(String(describing: bottomInterface))")

          guard let bottomInterfaceType = SCNetworkInterfaceGetInterfaceType(bottomInterface) else {
            Log.error("SCNetworkServiceGetInterface failed")
            return 999
          }

          if bottomInterfaceType != kSCNetworkInterfaceTypeL2TP {
            Log.debug("Ignoring Service \(serviceName) (\(bottomInterfaceType) on top of \(interfaceType))")
            continue
          }

          Log.debug("Found L2TP over IPSec Service \(serviceName) with ID \(serviceID)")
        } else {
          Log.debug("Found Cisco over IPSec Service \(serviceName) with ID \(serviceID)")
        }


        if !names.contains(serviceName as String) && !all {
          Log.debug("But I'm not deleting it because you didn't ask me to delete this one")
          continue
        }

       // Log.debug("interfaceType = \(interfaceType)")
       // Log.debug("serviceName = \(serviceName)")
//
       // Log.debug("serviceID = \(serviceID)")
       // Log.debug("")
//
        //if name != serviceName {
        //  Log.debug("Ignoring existing Service \(serviceName)")
        //  continue
        //}


        Log.debug("Deleting Service \(serviceName)")
        //continue

        if SCNetworkServiceRemove(existingService) {
          Log.info("Successfully deleted VPN Service \(serviceName)")
          deletedCount += 1;
        } else {
          Log.error("Error: Could not remove VPN service \(serviceName) from current network set. \(SCErrorString(SCError())) (Code \(SCError()))")
          return ExitCode.RemovingServiceFailed
        }
      }

      if (deletedCount == 0) {
        Log.error("No VPN Service was deleted. Are you sure it exists?")
        return ExitCode.NoServicesRemoved
      }

      Log.debug("Commiting all changes...")
      if !SCPreferencesCommitChanges(usingPreferencesRef) {
        Log.error("Sorry, without superuser privileges I won't be able to remove any VPN interfaces.");
        Log.debug("Error: Could not commit preferences after removing service(s). \(SCErrorString(SCError())) (Code \(SCError()))")
        return ExitCode.CommingingPreferencesFailed
      }
      if !SCPreferencesApplyChanges(usingPreferencesRef) {
        Log.error("Error: Could not apply changes after removing service(s). \(SCErrorString(SCError())) (Code \(SCError()))")
        return ExitCode.ApplyingPreferencesFailed
      }

      return ExitCode.Success
    }
  }
}
