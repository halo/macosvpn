/*
 Copyright (c) 2019 halo. https://github.com/halo/macosvpn

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

extension NetworkSet {
  public enum RemoveServices {
    public static func call(withName name: String,
                            fromNetworkSet networkSet: SCNetworkSet) throws {

      let services = try NetworkSet.Services.call(fromNetworkSet: networkSet)

      for service in services {
        if name != service.name {
          Log.debug("I'm not deleting \(service.name) because you didn't ask me to using `\(Flag.All.dashed) \"\(service.name)\"`")
          continue
        }

        Log.warn("You already have a service with the name `\(name)`.")
        Log.debug("That Service has the ID `\(service.id)`.")

        if !Arguments.options.forceRequested {
          throw ExitError(message: "If you want me to overwrite it, you need to specify the `--force` flag",
                          code: .refusingToOverwriteExistingService)
        }

        Log.info("Removing conflicting VPN Service with the name `\(name)` because you specified the `--force` flag.")

        guard SCNetworkServiceRemove(service.service) else {
          throw ExitError(message: "Could not remove duplicate VPN service `\(name)` from current network set",
                          code: .removingDuplicateServiceFailed,
                          systemStatus: true)
        }
        Log.debug("Successfully removed duplicate VPN Service \(name).")
      }
    }

    public static func call(withNames names: [String],
                            orAll all: Bool,
                            usingPreferencesRef preferences: SCPreferences) throws -> Int {

      var deletedCount: Int = 0
      let networkSet = try NetworkSet.Current.call(usingPreferencesRef: preferences)
      let services = try NetworkSet.Services.call(fromNetworkSet: networkSet)

      for service in services {

        if !all && !names.contains(service.name as String) {
          Log.debug("I'm not deleting \(service.name) because you didn't ask me to using `\(Flag.All.dashed) \"\(service.name)\"`")
          continue
        }

        Log.debug("Deleting Service `\(service.name)`...")
        //continue

        if SCNetworkServiceRemove(service.service) {
          Log.info("Successfully deleted VPN Service \(service.name)")
          deletedCount += 1;
        } else {
          Log.error("Error: Could not remove VPN service \(service.name) from current network set. \(SCErrorString(SCError())) (Code \(SCError()))")
          throw ExitError(message: "", code: .removingServiceFailed)
        }
      }

      if (names.count > 0 && deletedCount == 0) {
        Log.error("No VPN Service was deleted. Are you sure the specified name(s) exists?")
        throw ExitError(message: "", code: .noServicesRemoved)
      }

      return deletedCount
    }
  }
}
