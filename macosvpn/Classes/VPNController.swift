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

import SystemConfiguration

class VPNController {

  class func main() -> Int32 {
    Arguments.load()

    // Adding the --version flag should never perform anything but showing the version without any blank rows
    if Arguments.options.command == .version{
      return VPNHelp.showVersion()
    }

    // For readability we print out an empty row before and after.
    Log.info("")
    let exitCode: Int32 = self.run()
    Log.info("")

    // Mention that there were no errors so we can trace bugs more easily.
    if exitCode == 0 {
      Log.info("Finished without errors.")
      Log.info("")
    }
    return exitCode
  }

  class func run() -> Int32 {

    // Adding the --help flag should never perform anything but showing help
    if Arguments.options.command == .help {
      return VPNHelp.showHelp()
    }
    // To keep this application extensible we introduce different
    // commands right from the beginning. We start off with "create"
    if Arguments.options.command == .create {
      Log.debug("So, you wish to create one or more VPN service(s).")
      return self.create()
    }
    else if Arguments.options.command == .delete {
      Log.debug("So, you wish to delete one or more VPN service(s).")
      return self.delete()
    }
    else {
      Log.error("Unknown command. Try --help for instructions.")
      return 20
      // VPNExitCode.UnknownCommand
    }
  }

  /********************
   * INTERNAL METHODS *
   ********************/

  // This method is responsible for obtaining authorization in order to perform
  // privileged system modifications. It is mandatory for creating network interfaces.
  class func create() -> Int32 {

  // If this process has root privileges, it will be able to write to the System Keychain.
  // If not, we cannot (unless we use a helper tool, which is not the way this application is designed)
  // It would be nice to just try to perform the authorization and see if we succeeded or not.
  // But the Security System will popup an auth dialog, which is *not* enough to write to the System Keychain.
  // So, for now, we will simply bail out unless you called this command line application with the good old `sudo`.
  if (getuid() != 0) {
    Log.error("Sorry, without superuser privileges I won't be able to write to the System Keychain and thus cannot create a VPN service.");
    return VPNExitCode.PrivilegesRequired
  }

  let app = "macosvpn" as CFString
  guard let prefs: SCPreferences = SCPreferencesCreateWithAuthorization(nil, app, nil, VPNAuthorizations.create()) else {
    Log.error("Could not create Authorization.");
    return VPNExitCode.AuthorizationCreationFailed
  }

  // Making sure other process cannot make configuration modifications
  // by obtaining a system-wide lock over the system preferences.
    
  if (SCPreferencesLock(prefs, true)) {
    Log.debug("Gained superhuman rights.");
  } else {
    Log.error("Sorry, without superuser privileges I won't be able to add any VPN interfaces.");
    return VPNExitCode.LockingPreferencesFailed
  }

  // If everything works out, we will return exit code 0
  var exitCode: Int32 = 0;

  let serviceConfigs = Arguments.serviceConfigs
  if (serviceConfigs.count == 0) {
    Log.error("You did not specify any interfaces for me to create. Try --help for more information.");
    return VPNExitCode.MissingServices
  }

  // Each desired interface configuration will be processed in turn.
  // The configuration comes from the command line arguments and is passed on to the create method.
  for config: ServiceConfig in serviceConfigs {
    exitCode = Int32(ServiceConfig.Creator.create(config, usingPreferencesRef: prefs))
    // This particular interface could not be created. Let's stop processing the others.
    if (exitCode != 0) { break; } // VPNExitCode.Success
  }

  // We're done, other processes may modify the system configuration again
  SCPreferencesUnlock(prefs);
  return exitCode;
  }

  class func delete() -> Int32 {
    Log.debug("Shall we delete today?");
    // If everything works out, we will return exit code 0
    var exitCode: Int32 = 0;

    let names = Arguments.serviceNames
    //guard let names = Arguments.serviceNames else {
    //  Log.error("Could not extract service names.")
    //  return VPNExitCode.ServiceNameExtractionFailed;
    //}

    if (names.count == 0) {
      Log.error("You need to specify at least one --name MyVPNName.")
      return 23; // VPNExitCode.MissingNames
    }

    let app = "macosvpn" as CFString
    guard let prefs: SCPreferences = SCPreferencesCreateWithAuthorization(nil, app, nil, VPNAuthorizations.create()) else {
      Log.error("Could not create Authorization.");
      return 34; // VPNExitCode.AuthorizationCreationFailed
    }
    // Making sure other process cannot make configuration modifications
    // by obtaining a system-wide lock over the system preferences.
/*
    if (SCPreferencesLock(prefs, true)) {
      Log.debug("Gained superhuman rights.");
    } else {
      Log.error("Sorry, without superuser privileges I won't be able to remove any VPN interfaces.");
      return 32; // VPNExitCode.LockingPreferencesFailed
    }
*/
    for name: String in names {
      exitCode = Int32(VPNServiceRemover.removeService(name, usingPreferencesRef: prefs))
      // This particular interface could not be deleted. Let's stop processing the others.
      if (exitCode != 0) { break; } // VPNExitCode.Success
    }

    Log.debug((names.joined()))

    // We're done, other processes may modify the system configuration again
   // SCPreferencesUnlock(prefs);

    return exitCode;
  }
}
