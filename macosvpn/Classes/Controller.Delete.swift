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
