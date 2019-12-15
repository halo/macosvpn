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

/// A friendly wrapper for `SCNetworkService`
extension NetworkSet {
  public struct Service {
    public var service: SCNetworkService
    public var id: String
    public var name: String

    public var isCiscoOrL2TP: Bool {
      isCisco || isL2TP
    }

    public var isCisco: Bool {
      interfaceType == kSCNetworkInterfaceTypeIPSec
    }

    public var isL2TP: Bool {
      interfaceType == kSCNetworkInterfaceTypePPP &&
        bottomInterfaceType == kSCNetworkInterfaceTypeL2TP
    }

    public init(service: SCNetworkService) throws {
      self.service = service

      guard let id = SCNetworkServiceGetServiceID(service) else {
        throw ExitError(message: "Could not get Service ID", code: .todo)
      }
      self.id = id as String

      guard let name = SCNetworkServiceGetName(service) else {
        throw ExitError(message: "Could not get Service name", code: .todo)
      }
      self.name = name as String

      guard let interface = SCNetworkServiceGetInterface(service) else {
        throw ExitError(message: "Could not get Service Interface", code: .todo)
      }
      self.interface = interface

      guard let interfaceType = SCNetworkInterfaceGetInterfaceType(interface) else {
        throw ExitError(message: "Could not get Service Interface Type", code: .todo)
      }
      self.interfaceType = interfaceType

      if interfaceType != kSCNetworkInterfaceTypePPP { return }

      guard let bottomInterface = SCNetworkInterfaceGetInterface(interface) else {
        throw ExitError(message: "Could not get bottom interface of PPP service", code: .todo)
      }
      self.bottomInterface = bottomInterface

      guard let bottomInterfaceType = SCNetworkInterfaceGetInterfaceType(bottomInterface) else {
        throw ExitError(message: "Could not get type of bottom interface of PPP service", code: .todo)
      }
      self.bottomInterfaceType = bottomInterfaceType
    }

    private var interface: SCNetworkInterface
    private var interfaceType: CFString
    private var bottomInterface: SCNetworkInterface?
    private var bottomInterfaceType: CFString?
  }
}
