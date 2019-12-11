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

enum NetworkInterface {
  enum Initialize {
    static func call(kind: ServiceConfig.Kind) throws -> SCNetworkInterface {
      switch kind {

      case .L2TPOverIPSec:
        Log.debug("Initializing L2TP Interface on top of IPv4...")
        guard let bottomInterface = SCNetworkInterfaceCreateWithInterface(kSCNetworkInterfaceIPv4, kSCNetworkInterfaceTypeL2TP) else {
          throw ExitError(message: "Could not initialize L2TP Interface on top of IPv4",
                          code: .couldNotInitializeL2TPInterface)
        }

        Log.debug("Initializing PPP Interface on top of L2TP...")
        guard let topInterface = SCNetworkInterfaceCreateWithInterface(bottomInterface, kSCNetworkInterfaceTypePPP) else {
          throw ExitError(message: "Could not initialize L2TP Interface on top of IPv4",
                          code: .couldNotInitializePPPInterface)
        }
        return topInterface

      case .CiscoIPSec:
        Log.debug("Initializing IPSec Interface on top of IPv4")
        // Cisco IPSec (without underlying interface)
        guard let topInterface = SCNetworkInterfaceCreateWithInterface(kSCNetworkInterfaceIPv4, kSCNetworkInterfaceTypeIPSec) else {
          throw ExitError(message: "Could not initialize L2TP Interface on top of IPv4",
                          code: .couldNotInitializeIPSecInterface)
        }
        return topInterface

      }
    }
  }
}
