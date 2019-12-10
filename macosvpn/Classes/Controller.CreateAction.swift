import Darwin
import SystemConfiguration

extension Controller {
  public enum CreateAction {
     // This method is responsible for obtaining authorization in order to perform
    // privileged system modifications. It is mandatory for creating network interfaces.
    public static func call() throws {

      // If this process has root privileges, it will be able to write to the System Keychain.
      // If not, we cannot (unless we use a helper tool, which is not the way this application is designed)
      // It would be nice to just try to perform the authorization and see if we succeeded or not.
      // But the Security System will popup an auth dialog, which is *not* enough to write to the System Keychain.
      // So, for now, we will simply bail out unless you called this command line application with the good old `sudo`.
      guard getuid() == 0 else {
        throw ExitError(message: "Sorry, without superuser privileges I won't be able to write to the System Keychain and thus cannot create a VPN service",
                        code: .privilegesRequired)
      }

      let prefs = try Authorization.preferences()

      // Making sure other processes cannot make configuration modifications
      // by obtaining a system-wide lock over the system preferences.
      guard SCPreferencesLock(prefs, true) else {
        throw ExitError(message: "Sorry, without superuser privileges I won't be able to write to lock System Preferences and thus cannot create a VPN service",
                        code: .todo)
      }
      Log.debug("Gained superhuman rights.");
      // Later, when we're done, other processes may modify the system configuration again
      defer { SCPreferencesUnlock(prefs) }


      // If everything works out, we will return exit code 0
      var exitCode: Int32 = 0;

      let serviceConfigs = Arguments.serviceConfigs
      if (serviceConfigs.count == 0) {
        throw ExitError(message: "You did not specify any interfaces for me to create. Try --help for more information.",
                        code: .todo)
      }

      // Each desired interface configuration will be processed in turn.
      // The configuration comes from the command line arguments and is passed on to the create method.
      for config: ServiceConfig in serviceConfigs {
        exitCode = Int32(try ServiceConfig.Creator.create(config, usingPreferencesRef: prefs))
        // This particular interface could not be created. Let's stop processing the others.
        if (exitCode != 0) { break; } // VPNExitCode.Success
      }

    }
  }
}
