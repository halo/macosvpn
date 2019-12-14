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

import Security

extension Keychain {
  enum CreateItem {
    static func create(_ label: String,
                       withService service: String,
                       account: String,
                       description: String,
                       andPassword password: String) throws {
      Log.debug("Creating System Keychain for \(label) with service \(service) and account \(account) and description \(description) and password? \(!password.isEmpty)")

      let keychain = try Keychain.Retrieve.systemKeychain()


      // This variable is going to hold our new Keychain Item


      var trustedApplications: [SecTrustedApplication] = []

      for path in trustedAppPaths {
        var appPointer: SecTrustedApplication?

        let appCreateStatus = SecTrustedApplicationCreateFromPath(path.toUnsafeMutablePointer(), &appPointer)
        guard appCreateStatus == errSecSuccess else {
          Log.error("Could not create trusted application: \(String(describing: SecCopyErrorMessageString(appCreateStatus, nil)))")
          throw ExitError(message: "", code: .todo)
        }

        guard let app = appPointer else {
          Log.error("Created trusted application is nil: \(String(describing: SecCopyErrorMessageString(appCreateStatus, nil)))")
         throw ExitError(message: "", code: .todo)
        }

        trustedApplications.append(app)
      }


      var access: SecAccess? = nil
      let accessStatus = SecAccessCreate("macosvpn VPN Service Password" as CFString,
                                         trustedApplications as CFArray,
                                         &access)

      guard accessStatus == errSecSuccess else {
        Log.error("Could not unlock System Keychain: \(String(describing: SecCopyErrorMessageString(accessStatus, nil)))")
        throw ExitError(message: "", code: .todo)
      }
      Log.debug("Created empty Keychain access object")

      guard let labelPointer = label.toUnsafeMutablePointer() else {
        Log.error("Could not convert label \(label) to pointer")
        throw ExitError(message: "", code: .todo)
      }

      guard let accountPointer = account.toUnsafeMutablePointer() else {
        Log.error("Could not convert account \(account) to pointer")
        throw ExitError(message: "", code: .todo)
      }

      guard let servicePointer = service.toUnsafeMutablePointer() else {
        Log.error("Could not convert service \(service) to pointer")
        throw ExitError(message: "", code: .todo)
      }

      guard let descriptionPointer = description.toUnsafeMutablePointer() else {
        Log.error("Could not convert description \(description) to pointer")
        throw ExitError(message: "", code: .todo)
      }

      guard let passwordPointer = password.toUnsafeMutablePointer() else {
        Log.error("Could not convert password \(password) to pointer")
        throw ExitError(message: "", code: .todo)
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


      guard createStatus == errSecSuccess else {
        Log.error("Creating Keychain item failed: \(String(describing: SecCopyErrorMessageString(createStatus, nil)))")
        throw ExitError(message: "", code: .todo)
      }

      Log.debug("Successfully created Keychain Item")
    }

    private static var trustedAppPaths: [String] {
      [
        "/System/Library/Frameworks/SystemConfiguration.framework/Versions/A/Helpers/SCHelper",
        "/System/Library/PreferencePanes/Network.prefPane/Contents/XPCServices/com.apple.preference.network.remoteservice.xpc",
        "/System/Library/CoreServices/SystemUIServer.app",
        "/usr/sbin/pppd",
        "/usr/sbin/racoon",
        "/usr/libexec/configd"
      ]
    }
  }
}
