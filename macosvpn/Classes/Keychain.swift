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

struct Keychain {
  public static func createPasswordKeyChainItem(_ label: String, forService service: String, withAccount account: String, andPassword password: String) -> Int32 {
    Log.debug("Creating Password Keychain Item with ID \(String(describing: service))")
    return self.createItem(label, withService: service, account: account, description: "PPP Password", andPassword: password)
  }

  public static func createSharedSecretKeyChainItem(_ label: String, forService service: String, withPassword password: String) -> Int32 {
    var service = service
    service = "\(service ).SS"
    Log.debug("Creating IPSec Shared Secret Keychain Item with ID \(String(describing: service))")
    return self.createItem(label, withService: service, account: "", description: "IPSec Shared Secret", andPassword: password)
  }

  public static func createXAuthKeyChainItem(_ label: String, forService service: String, withPassword password: String) -> Int32 {
    var service = service
    service = "\(service ).XAUTH"
    Log.debug("Creating Cisco IPSec XAuth Keychain Item with ID \(String(describing: service))")
    return self.createItem(label, withService: service, account: "", description: "IPSec XAuth Password", andPassword: password)
  }

  public static func createItem(_ label: String,
                                withService service: String,
                                account: String,
                                description: String,
                                andPassword password: String) -> Int32 {
    Log.debug("Creating System Keychain for \(label)")

    // This variable is soon to hold the System Keychain
    var keychain: SecKeychain? = nil

    let copyStatus = SecKeychainCopyDomainDefault(SecPreferencesDomain.system, &keychain)
    guard copyStatus == errSecSuccess else {
      Log.error("Could not obtain System Keychain: \(String(describing: SecCopyErrorMessageString(copyStatus, nil)))")
      return 60
    }
    Log.debug("Succeeded opening System Keychain")

    Log.debug("Unlocking System Keychain")
    let unlockStatus = SecKeychainUnlock(keychain, 0, nil, false)
    
    guard unlockStatus == errSecSuccess else {
      Log.error("Could not unlock System Keychain: \(String(describing: SecCopyErrorMessageString(unlockStatus, nil)))")
      return 61
    }
    Log.debug("Succeeded unlocking System Keychain")

    // This variable is going to hold our new Keychain Item

    let trustedAppPaths = [
      "/System/Library/Frameworks/SystemConfiguration.framework/Versions/A/Helpers/SCHelper",
      "/System/Library/PreferencePanes/Network.prefPane/Contents/XPCServices/com.apple.preference.network.remoteservice.xpc",
      "/System/Library/CoreServices/SystemUIServer.app",
      "/usr/sbin/pppd",
      "/usr/sbin/racoon",
      "/usr/libexec/configd"
    ]

    var trustedApplications: [SecTrustedApplication] = []

    for path in trustedAppPaths {
      var appPointer: SecTrustedApplication?

      let appCreateStatus = SecTrustedApplicationCreateFromPath(path.toUnsafeMutablePointer(), &appPointer)
      guard unlockStatus == errSecSuccess else {
        Log.error("Could not create trusted application: \(String(describing: SecCopyErrorMessageString(appCreateStatus, nil)))")
        return 999
      }

      guard let app = appPointer else {
        Log.error("Created trusted application is nil: \(String(describing: SecCopyErrorMessageString(appCreateStatus, nil)))")
        return 999
      }

      trustedApplications.append(app)
    }


    var access: SecAccess? = nil
    let accessStatus = SecAccessCreate("macosvpn VPN Service Password" as CFString,
                                       trustedApplications as CFArray,
                                       &access)

    guard accessStatus == errSecSuccess else {
      Log.error("Could not unlock System Keychain: \(String(describing: SecCopyErrorMessageString(accessStatus, nil)))")
      return 62
    }
    Log.debug("Created empty Keychain access object")

    // Converting the NSStrings to char* variables which we will need later
    guard let labelPointer = label.toUnsafeMutablePointer() else {
      Log.error("Could not convert label \(label) to pointer")
      return 999
    }

    guard let accountPointer = account.toUnsafeMutablePointer() else {
      Log.error("Could not convert account \(account) to pointer")
      return 999
    }

    guard let servicePointer = service.toUnsafeMutablePointer() else {
      Log.error("Could not convert service \(service) to pointer")
      return 999
    }

    guard let descriptionPointer = description.toUnsafeMutablePointer() else {
      Log.error("Could not convert description \(description) to pointer")
      return 999
    }

    guard let passwordPointer = password.toUnsafeMutablePointer() else {
      Log.error("Could not convert password \(password) to pointer")
      return 999
    }

    var attributes: [SecKeychainAttribute] = [
      SecKeychainAttribute(tag: SecItemAttr.labelItemAttr.rawValue,
                           length: UInt32(strlen(labelPointer)),
                           data: labelPointer),

      SecKeychainAttribute(tag: SecItemAttr.accountItemAttr.rawValue,
                           length: UInt32(strlen(accountPointer)),
                           data: accountPointer),

      SecKeychainAttribute(tag: SecItemAttr.serviceItemAttr.rawValue,
                           length: UInt32(strlen(servicePointer)),
                           data: servicePointer),

      SecKeychainAttribute(tag: SecItemAttr.descriptionItemAttr.rawValue,
                           length: UInt32(strlen(descriptionPointer)),
                           data: descriptionPointer),
    ]


    var attributesList = SecKeychainAttributeList(count: UInt32(attributes.count), attr: &attributes)

    var item: SecKeychainItem? = nil
    let createStatus = SecKeychainItemCreateFromContent(SecItemClass.genericPasswordItemClass,
                                                        &attributesList,
                                                        UInt32(strlen(passwordPointer)),
                                                        passwordPointer,
                                                        keychain,
                                                        access,
                                                        &item)


    //status = SecKeychainItemCreateFromContent(SecItemClass.genericPasswordItemClass, &attributes, Int(strlen(passwordUTF8)), passwordUTF8, keychain, access, &item)
    guard createStatus == errSecSuccess else {
      Log.error("Creating Keychain item failed: \(String(describing: SecCopyErrorMessageString(createStatus, nil)))")
      return 63
    }

    Log.debug("Successfully created Keychain Item")
    return VPNExitCode.Success
  }

}
