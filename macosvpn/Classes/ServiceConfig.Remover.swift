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

      let deletedCount = try NetworkSet.RemoveServices.call(withNames: names,
                                                            orAll: all,
                                                            usingPreferencesRef: preferences)

      if (deletedCount == 0) {
        Log.debug("No services had to be deleted. No need to commit any changes.")
        return
      }

      Log.debug("Commiting all changes...")
      if !SCPreferencesCommitChanges(preferences) {
        throw ExitError(message: "Could not commit preferences after removing service(s)",
                        code: .committingPreferencesFailed,
                        systemStatus: true)
      }
      if !SCPreferencesApplyChanges(preferences) {
        throw ExitError(message: "Could not apply changes after removing service(s)",
                        code: .applyingPreferencesFailed,
                        systemStatus: true)
      }

    }
  }
}
