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
#import <SystemConfiguration/SystemConfiguration.h>

// Local dependencies
#import "VPNArguments.h"
#import "VPNController.h"
#import "VPNKeychain.h"
#import "VPNServiceConfig.h"
#import "VPNServiceCreator.h"

// This is were the magic happens.
// Exit status codes: 30-59
@implementation VPNController

/******************
 * PUBLIC METHODS *
 ******************/

// The single entry point. This method is executed first.
+ (int) main {

  // Adding the --version flag should never perform anything but showing the version without any blank rows
  if ([VPNArguments versionRequested]) return [VPNHelp showVersion];

  // For readability we print out an empty row before and after.
  DDLogInfo(@"");
  int exitCode = [self run];
  DDLogInfo(@"");

  // Mention that there were no errors so we can trace bugs more easily.
  if (exitCode == 0) {
    DDLogInfo(@"Finished without errors.");
    DDLogInfo(@"");
  }
  return exitCode;
}

+ (int) run {
  // Adding the --help flag should never perform anything but showing help
  if ([VPNArguments helpRequested]) return [VPNHelp showHelp];

  // To keep this application extensible we introduce different
  // commands right from the beginning. We start off with "create"
  if ([VPNArguments command] == VPNCommandCreate) {
    DDLogDebug(@"So, you wish to create one or more VPN service(s).");
    return [self create];

  } else {
    DDLogError(@"Unknown command. Try --help for instructions.");
    return 30;
  }
}

/********************
 * INTERNAL METHODS *
 ********************/

// This method is responsible for obtaining authorization in order to perform
// privileged system modifications. It is mandatory for creating network interfaces.
+ (int) create {

  // If this process has root privileges, it will be able to write to the System Keychain.
  // If not, we cannot (unless we use a helper tool, which is not the way this application is designed)
  // It would be nice to just try to perform the authorization and see if we succeeded or not.
  // But the Security System will popup an auth dialog, which is *not* enough to write to the System Keychain.
  // So, for now, we will simply bail out unless you called this command line application with the good old `sudo`.
  if (getuid() != 0) {
    DDLogError(@"Sorry, without superuser privileges I won't be able to write to the System Keychain and thus cannot create a VPN service.");
    return 31;
  }
  
  // Obtaining permission to modify network settings
  SCPreferencesRef prefs = SCPreferencesCreateWithAuthorization(NULL, CFSTR("macosvpn"), NULL, [VPNAuthorizations create]);

  // Making sure other process cannot make configuration modifications
  // by obtaining a system-wide lock over the system preferences.
  if (SCPreferencesLock(prefs, TRUE)) {
    DDLogDebug(@"Gained superhuman rights.");
  } else {
    DDLogError(@"Sorry, without superuser privileges I won't be able to add any VPN interfaces.");
    return 31;
  }

  // If everything works out, we will return exit code 0
  int exitCode = 0;

  NSArray *serviceConfigs = [VPNArguments serviceConfigs];
  if (serviceConfigs.count == 0) {
    DDLogError(@"You did not specify any interfaces for me to create. Try --help for more information.");
    return 43;
  }

  // Each desired interface configuration will be processed in turn.
  // The configuration comes from the command line arguments and is passed on to the create method.
  for (VPNServiceConfig *config in serviceConfigs) {
    exitCode = [VPNServiceCreator createService:config usingPreferencesRef:prefs];
    // This particular interface could not be created. Let's stop processing the others.
    if (exitCode != 0) break;
  }

  // We're done, other processes may modify the system configuration again
  SCPreferencesUnlock(prefs);
  return exitCode;
}

@end
