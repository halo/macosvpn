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

import Foundation
import Security.SecKeychain

enum Keychain {
  public static func createPasswordKeyChainItem(_ label: String,
                                                forService service: String,
                                                withAccount account: String,
                                                andPassword password: String) throws {
    Log.debug("Creating Password Keychain Item with ID \(String(describing: service))")
    try CreateItem.create(label, withService: service, account: account, description: "PPP Password", andPassword: password)
  }

  public static func createSharedSecretKeyChainItem(_ label: String,
                                                    forService service: String,
                                                    withPassword password: String) throws {
    var service = service
    service = "\(service).SS"
    Log.debug("Creating Cisco IPSec Shared Secret Keychain Item with ID \(String(describing: service))")
    try CreateItem.create(label, withService: service, account: "", description: "IPSec Shared Secret", andPassword: password)
  }

  public static func createXAuthKeyChainItem(_ label: String,
                                             forService service: String,
                                             withPassword password: String) throws {
    var service = service
    service = "\(service ).XAUTH"
    Log.debug("Creating Cisco IPSec XAuth Keychain Item with ID \(String(describing: service))")
    try CreateItem.create(label, withService: service, account: "", description: "IPSec XAuth Password", andPassword: password)
  }


}
