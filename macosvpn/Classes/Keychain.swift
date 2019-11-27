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

// See https://stackoverflow.com/a/55986029

extension String {
    func toUnsafePointer() -> UnsafePointer<UInt8>? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }

        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        let stream = OutputStream(toBuffer: buffer, capacity: data.count)
        stream.open()
        let value = data.withUnsafeBytes {
            $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
        }
        guard let val = value else {
            return nil
        }
        stream.write(val, maxLength: data.count)
        stream.close()

        return UnsafePointer<UInt8>(buffer)
    }

    func toUnsafeMutablePointer() -> UnsafeMutablePointer<Int8>? {
        return strdup(self)
    }
}

struct Keychain {
  private let trustedAppPaths = [
    "/System/Library/Frameworks/SystemConfiguration.framework/Versions/A/Helpers/SCHelper",
    "/System/Library/PreferencePanes/Network.prefPane/Contents/XPCServices/com.apple.preference.network.remoteservice.xpc",
    "/System/Library/CoreServices/SystemUIServer.app",
    "/usr/sbin/pppd",
    "/usr/sbin/racoon",
    "/usr/libexec/configd"
  ] 

  public static func createPasswordKeyChainItem(_ label: String, forService service: String, withAccount account: String, andPassword password: String) -> Int {
    Log.debug("Creating Password Keychain Item with ID \(String(describing: service))")
    return self.createItem(label, withService: service, account: account, description: "PPP Password", andPassword: password)
  }

  public static func createSharedSecretKeyChainItem(_ label: String, forService service: String, withPassword password: String) -> Int {
    var service = service
    service = "\(service ).SS"
    Log.debug("Creating IPSec Shared Secret Keychain Item with ID \(String(describing: service))")
    return self.createItem(label, withService: service, account: "", description: "IPSec Shared Secret", andPassword: password)
  }

  public static func createXAuthKeyChainItem(_ label: String, forService service: String, withPassword password: String) -> Int {
    var service = service
    service = "\(service ).XAUTH"
    Log.debug("Creating Cisco IPSec XAuth Keychain Item with ID \(String(describing: service))")
    return self.createItem(label, withService: service, account: "", description: "IPSec XAuth Password", andPassword: password)
  }

  public static func createItem(_ label: String,
                                withService service: String,
                                account: String,
                                description: String,
                                andPassword password: String) -> Int {
    Log.debug("Creating System Keychain for \(label)")

    // This variable will hold all sorts of operation status responses
    var status: OSStatus

    // Converting the NSStrings to char* variables which we will need later
    let labelUTF8 = label.toUnsafeMutablePointer()
    let serviceUTF8 = service.toUnsafeMutablePointer()
    let accountUTF8 = account.toUnsafeMutablePointer()
    let descriptionUTF8 = description.toUnsafeMutablePointer()
    let passwordUTF8 = password.toUnsafeMutablePointer()

    // This variable is soon to hold the System Keychain
    var keychain: SecKeychain? = nil

    status = SecKeychainCopyDomainDefault(SecPreferencesDomain.system, &keychain)
    if status == errSecSuccess {
      Log.debug("Succeeded opening System Keychain")
    } else {
      Log.error("Could not obtain System Keychain: \(String(describing: SecCopyErrorMessageString(status, nil)))")
      return 60
    }

    Log.debug("Unlocking System Keychain")
    status = SecKeychainUnlock(keychain, 0, nil, false)
    if status == errSecSuccess {
      Log.debug("Succeeded unlocking System Keychain")
    } else {
      Log.error("Could not unlock System Keychain: \(String(describing: SecCopyErrorMessageString(status, nil)))")
      return 61
    }

    // This variable is going to hold our new Keychain Item
    var item: SecKeychainItem? = nil

    var access: SecAccess? = nil
    //status = SecAccessCreate("Some VPN Test" as CFString, (self.trustedApps) as? CFArray?, &access)
    status = SecAccessCreate("Some VPN Test" as CFString, [] as CFArray, &access)

    if status == 0 {
      Log.debug("Created empty Keychain access object")
    } else {
      Log.error("Could not unlock System Keychain: \(String(describing: SecCopyErrorMessageString(status, nil)))")
      return 62
    }

    //var attrs: [SecKeychainAttribute] = [
    //  (.labelItemAttr, Int(strlen(labelUTF8)), Int8(labelUTF8)),
    //  (.accountItemAttr, Int(strlen(accountUTF8)), Int8(accountUTF8)),
    //  (.serviceItemAttr, Int(strlen(serviceUTF8)), Int8(serviceUTF8)),
    //  (.descriptionItemAttr, Int(strlen(descriptionUTF8)), Int8(descriptionUTF8))
    //]
//
    var attrs: [SecKeychainAttribute] = []

    //SecKeychainAttribute(tag: SecKeychainAttrType, length: len, data: utfString)

    var attrList = SecKeychainAttributeList(count: UInt32(attrs.count), attr: &attrs)
    //let pass = (password as NSString).utf8String
    //let len = UInt32(truncatingBitPattern: strlen(pass))

    status = SecKeychainItemCreateFromContent(SecItemClass.genericPasswordItemClass, &attrList, UInt32(strlen(passwordUTF8!)), passwordUTF8, keychain, access,  &item)

//
    //status = SecKeychainItemCreateFromContent(SecItemClass.genericPasswordItemClass, &attributes, Int(strlen(passwordUTF8)), passwordUTF8, keychain, access, &item)

    if status == 0 {
      Log.debug("Successfully created Keychain Item")
    } else {
      Log.error("Creating Keychain item failed: \(String(describing: SecCopyErrorMessageString(status, nil)))")
      return 63
    }

    return 0
  }

  // See https://gist.github.com/rinatkhanov/a837f1e53c3f921db131
  //private static func createAttribute(tag: Int, _ data: String?) -> SecKeychainAttribute? {
  //       if var data = data {
  //           let utfString = UnsafeMutablePointer<Int8>((data as NSString).UTF8String)
  //           let len = UInt32(truncatingBitPattern: strlen(utfString))
  //           return SecKeychainAttribute(tag: SecKeychainAttrType(tag), length: len, data: utfString)
  //       } else {
  //           return nil
  //       }
  //   }
}
