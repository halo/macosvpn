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
    static func delete(names: [String], all: Bool, usingPreferencesRef preferences: SCPreferences) throws {

      if all {
        Log.debug("Removing all L2TP and Cisco Services")
      } else {
        Log.debug("Removing Services \(names)")
      }

      try NetworkSet.RemoveServices.call(withNames: names, orAll: all, usingPreferencesRef: preferences)

      Log.debug("Commiting all changes...")
      if !SCPreferencesCommitChanges(preferences) {
        Log.error("Sorry, without superuser privileges I won't be able to remove any VPN interfaces.");
        Log.debug("Error: Could not commit preferences after removing service(s). \(SCErrorString(SCError())) (Code \(SCError()))")
        throw ExitError(message: "", code: .todo)   // CommingingPreferencesFailed
      }
      if !SCPreferencesApplyChanges(preferences) {
        Log.error("Error: Could not apply changes after removing service(s). \(SCErrorString(SCError())) (Code \(SCError()))")
        throw ExitError(message: "", code: .todo)   // ApplyingPreferencesFailed
      }

    }
  }
}
