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

extension Controller {
  public enum Delete {
    public static func call() throws {
      Log.debug("Shall we delete today?");

      let names = Arguments.options.names

      if (names.count == 0 && !Arguments.options.allRequested) {
        throw ExitError(message: "You need to specify at least one `--name MyVPNName` or use `--all` to delete all L2TP and Cisco VPNs",
                        code: .unclearWhichServicesToDelete)
      }

      let prefs = try Authorization.preferences()

      guard SCPreferencesLock(prefs, true) else {
        throw ExitError(message: "Could not obtain global System Preferences Lock.",
                        code: .couldNotLockSystemPreferences,
                        systemStatus: true)
      }
      defer { SCPreferencesUnlock(prefs) }

      try ServiceConfig.Remover.delete(names: names,
                                   all: Arguments.options.allRequested,
                                   usingPreferencesRef: prefs)
      // This particular interface could not be deleted. Let's stop processing the others.

      // We're done, other processes may modify the system configuration again
       SCPreferencesUnlock(prefs);
    }
  }
}
