/*
 * Copyright (C) 2014-2019 halo https://github.com/halo/macosvpn
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import SystemConfiguration

extension NetworkSet {
  public enum Services {
    public static func call(fromNetworkSet networkSet: SCNetworkSet) throws -> [Service] {
      var result: [Service] = []

      Log.debug("Fetching all services from network set...")
      guard let services = SCNetworkSetCopyServices(networkSet) else {
        throw ExitError(message: "Could not fetch all services from network set",
                        code: .couldNotRetrieveServicesFromNetworkSet)
      }

      for serviceWrapper in services as! [SCNetworkService] {
        let service = try Service.init(service: serviceWrapper)

        if !service.isCiscoOrL2TP {
          // Wisely excluding all non-relevant services right from the start.
          // So we do not accidentally delete a Bluetooth or Wi-Fi service :)
          Log.debug("Ignoring irrelevant Service \(service.name)")
          continue
        }

        result.append(service)
      }

      return result.filter { $0.isCiscoOrL2TP }
    }

  }

}
