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

import Security

extension Keychain {
  enum Retrieve {
    public static func systemKeychain() throws -> SecKeychain {
      Log.debug("Retrieving System Keychain...")
      var secKeychain: SecKeychain? = nil

      let copyStatus = SecKeychainCopyDomainDefault(
        SecPreferencesDomain.system,
        &secKeychain
      )

      guard copyStatus == errSecSuccess else {
        throw ExitError(message: "Could not retrieve System Keychain",
                        code: .couldNotRetrieveSystemKeychain,
                        securityStatus: copyStatus)
      }

      guard let keychain = secKeychain else {
        throw ExitError(message: "Could not unwrap retrieved System Keychain",
                        code: .couldNotUnwrapSystemKeychain)
      }
      Log.debug("Successfully retrieved System Keychain")

      try unlock(keychain: keychain)
      return keychain
    }

    private static func unlock(keychain: SecKeychain) throws {
      Log.debug("Unlocking System Keychain...")

      let unlockStatus = SecKeychainUnlock(keychain, 0, nil, false)

      guard unlockStatus == errSecSuccess else {
        throw ExitError(message: "Could not unlock System Keychain",
                        code: .couldNotRetrieveSystemKeychain,
                        securityStatus: unlockStatus)
      }

      Log.debug("Succeeded unlocking System Keychain")
    }
  }
}
