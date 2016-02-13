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
#import "VPNAuthorizations.h"
#import "VPNController.h"
#import "VPNKeychain.h"
#import "VPNServiceConfig.h"

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

  // If everything will work out fine, we will return exit code 0
  int exitCode = 0;

  NSArray *serviceConfigs = [VPNArguments serviceConfigs];
  if (serviceConfigs.count == 0) {
    DDLogError(@"You did not specify any interfaces for me to create. Try --help for more information.");
    return 43;
  }

  // Each desired interface configuration will be processed in turn.
  // The configuration comes from the command line arguments and is passed on to the create method.
  for (VPNServiceConfig *config in serviceConfigs) {
    exitCode = [self createService:config usingPreferencesRef:prefs];
    // This particular interface could not be created. Let's stop processing the others.
    if (exitCode != 0) break;
  }

  // We're done, other processes may modify the system configuration again
  SCPreferencesUnlock(prefs);
  return exitCode;
}

// This method creates one VPN interface according to the desired configuration
+ (int) createService:(VPNServiceConfig*)config usingPreferencesRef:(SCPreferencesRef)prefs {
  DDLogDebug(@"Creating new %@ Service using %@", config.humanType, config);

  // These variables will hold references to our new interfaces
  SCNetworkInterfaceRef topInterface;
  SCNetworkInterfaceRef bottomInterface;

  switch (config.type) {
    case VPNServiceL2TPOverIPSec:
      DDLogDebug(@"L2TP Service detected...");
      // L2TP on top of IPv4
      bottomInterface = SCNetworkInterfaceCreateWithInterface(kSCNetworkInterfaceIPv4,kSCNetworkInterfaceTypeL2TP);
      // PPP on top of L2TP
      topInterface = SCNetworkInterfaceCreateWithInterface(bottomInterface, kSCNetworkInterfaceTypePPP);
      break;

    case VPNServiceCiscoIPSec:
      DDLogDebug(@"Cisco IPSec Service detected...");
      // Cisco IPSec (without underlying interface)
      topInterface = SCNetworkInterfaceCreateWithInterface (kSCNetworkInterfaceIPv4, kSCNetworkInterfaceTypeIPSec);
      break;
      
    default:
      DDLogError(@"Sorry, this service type is not yet supported");
      return 32;
      break;
  }

  DDLogDebug(@"Instantiating interface references...");
  DDLogDebug(@"Creating a new, fresh VPN service in memory using the interface we already created");
  SCNetworkServiceRef service = SCNetworkServiceCreate(prefs, topInterface);
  DDLogDebug(@"That service is to have a name");
  SCNetworkServiceSetName(service, (__bridge CFStringRef)config.name);
  DDLogDebug(@"And we also woould like to know the internal ID of this service");
  NSString *serviceID = (__bridge NSString *)(SCNetworkServiceGetServiceID(service));
  DDLogDebug(@"It will be used to find the correct passwords in the system keychain");
  config.serviceID = serviceID;

  // Interestingly enough, the interface variables in itself are now worthless.
  // We used them to create the service and that's it, we cannot modify or use them any more.
  DDLogDebug(@"Deallocating obsolete interface references...");
  CFRelease(topInterface);
  topInterface = NULL;
  if (bottomInterface) {
    CFRelease(bottomInterface);
    bottomInterface = NULL;
  }

  DDLogDebug(@"Reloading top Interface...");
  // Because, if we would like to modify the interface, we first need to freshly fetch it from the service
  // See https://lists.apple.com/archives/macnetworkprog/2013/Apr/msg00016.html
  topInterface = SCNetworkServiceGetInterface(service);

  // Error Codes 50-59
  
  switch (config.type) {
    case VPNServiceL2TPOverIPSec:
      DDLogDebug(@"Configuring %@ Service", config.humanType);
      
      // Let's apply all configuration to the PPP interface
      // Specifically, the servername, account username and password
      if (SCNetworkInterfaceSetConfiguration(topInterface, config.L2TPPPPConfig)) {
        DDLogDebug(@"Successfully configured PPP interface of service %@", config.name);
      } else {
        DDLogError(@"Error: Could not configure PPP interface for service %@", config.name);
        return 50;
      }
      
      // Now let's apply the shared secret to the IPSec part of the L2TP/IPSec Interface
      if (SCNetworkInterfaceSetExtendedConfiguration(topInterface, CFSTR("IPSec"), config.L2TPIPSecConfig)) {
        DDLogDebug(@"Successfully configured IPSec on PPP interface for service %@", config.name);
      } else {
        DDLogError(@"Error: Could not configure IPSec on PPP interface for service %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
        return 35;
      }
    break;
      
    case VPNServiceCiscoIPSec:
      DDLogDebug(@"Configuring %@ Service", config.humanType);

      // Let's apply all configuration data to the Cisco IPSec interface
      // As opposed to L2TP, here all configuration goes to the top Interface, i.e. the only Interface there is.
      if (SCNetworkInterfaceSetConfiguration(topInterface, config.ciscoConfig)) {
        DDLogDebug(@"Successfully configured Cisco IPSec interface of service %@", config.name);
      } else {
        DDLogError(@"Error: Could not configure Cisco IPSec interface for service %@", config.name);
        return 51;
      }
    break;
      
    default:
      DDLogError(@"Error: I cannot handle this interface type yet.");
      return 59;
    break;
  }
  
  // Error Codes ...

  DDLogDebug(@"Adding default protocols (DNS, etc.) to service %@...", config.name);
  if (!SCNetworkServiceEstablishDefaultConfiguration(service)) {
    DDLogError(@"Error: Could not establish a default service configuration for %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
    return 36;
  }

  DDLogDebug(@"Fetching set of all available network services...");
  SCNetworkSetRef networkSet = SCNetworkSetCopyCurrent(prefs);
  if (!networkSet) {
    DDLogError(@"Error: Could not fetch current network set when creating %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
    return 37;
  }

  if (!SCNetworkSetAddService (networkSet, service)) {
    if (SCError() == 1005) {
      DDLogWarn(@"Skipping VPN Service %@ because it already exists.", config.humanType);
      return 0;
    } else {
      DDLogError(@"Error: Could not add new VPN service %@ to current network set. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
      return 38;
    }
  }

  DDLogDebug(@"Fetching IPv4 protocol of service %@...", config.name);
  SCNetworkProtocolRef protocol = SCNetworkServiceCopyProtocol(service, kSCNetworkProtocolTypeIPv4);

  if (!protocol) {
    DDLogError(@"Error: Could not fetch IPv4 protocol of %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
    return 39;
  }

  DDLogDebug(@"Configuring IPv4 protocol of service %@...", config.name);
  if (!SCNetworkProtocolSetConfiguration(protocol, config.L2TPIPv4Config)) {
    DDLogError(@"Error: Could not configure IPv4 protocol of %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
    return 40;
  }

  DDLogDebug(@"Commiting all changes including service %@...", config.name);
  if (!SCPreferencesCommitChanges(prefs)) {
    DDLogError(@"Error: Could not commit preferences with service %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
    return 41;
  }

  DDLogDebug(@"Preparing to add Keychain items for service %@...", config.name);

  // The password and the shared secret are not stored directly in the System Preferences .plist file
  // Instead we put them into the KeyChain. I know we're creating new items each time you run this application
  // But this actually is the same behaviour you get using the official System Preferences Network Pane
  if (config.password) {
    [VPNKeychain createPasswordKeyChainItem:config.name forService:serviceID withAccount:config.username andPassword:config.password];
  }

  if (config.sharedSecret) {
    [VPNKeychain createSharedSecretKeyChainItem:config.name forService:serviceID withPassword:config.sharedSecret];
  }

  if (!SCPreferencesApplyChanges(prefs)) {
    DDLogError(@"Error: Could not apply changes with service %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
    return 42;
  }

  DDLogInfo(@"Successfully created %@ VPN %@ with ID %@", config.humanType, config.name, serviceID);
  return 0;
}

@end
