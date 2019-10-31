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
#import <Security/SecKeychain.h>

// Local dependencies
#import "VPNKeychain.h"

// These are the applications which are going to get access to new Keychain items.
// How do we know them? Just create a VPN service manualy and run the following command:
//   security dump-keychain -a /Library/Keychains/System.keychain
// Among the results, you will find your VPN service and you can see the paths that have access to it
static const char * trustedAppPaths[] = {
  "/System/Library/Frameworks/SystemConfiguration.framework/Versions/A/Helpers/SCHelper",
  "/System/Library/PreferencePanes/Network.prefPane/Contents/XPCServices/com.apple.preference.network.remoteservice.xpc",
  "/System/Library/CoreServices/SystemUIServer.app",
  "/usr/sbin/pppd",
  "/usr/sbin/racoon",
  "/usr/libexec/configd",
};

// This class contains all code we need to handle System Keychain Items
// Exit status codes: 60-79
@implementation VPNKeychain

/******************
 * PUBLIC METHODS *
 ******************/

// This will create a PPP Password Keychain Item
+ (int) createPasswordKeyChainItem:(NSString*)label forService:(NSString*)service withAccount:(NSString*)account andPassword:(NSString*)password {
  Log.debug(@"Creating Password Keychain Item with ID %@", service);
  return [self createItem:label withService:service account:account description:@"PPP Password" andPassword:password];
}

// This will create an IPSec Shared Secret Keychain Item
+ (int) createSharedSecretKeyChainItem:(NSString*)label forService:(NSString*)service withPassword:(NSString*)password {
  service = [NSString stringWithFormat:@"%@.SS", service];
  Log.debug(@"Creating IPSec Shared Secret Keychain Item with ID %@", service);
  return [self createItem:label withService:service account:@"" description:@"IPSec Shared Secret" andPassword:password];
}

// This will create an Cisco IPSec XAuth Keychain Item
+ (int) createXAuthKeyChainItem:(NSString*)label forService:(NSString*)service withPassword:(NSString*)password {
  service = [NSString stringWithFormat:@"%@.XAUTH", service];
  Log.debug(@"Creating Cisco IPSec XAuth Keychain Item with ID %@", service);
  return [self createItem:label withService:service account:@"" description:@"IPSec XAuth Password" andPassword:password];
}

/********************
 * INTERNAL METHODS *
 ********************/

// A generic method to create Keychain Items holding Network service passwords
+ (int) createItem:(NSString*)label withService:(NSString*)service account:(NSString*)account description:(NSString*)description andPassword:(NSString*)password {

  Log.debug(@"Creating System Keychain for %@", label);

  // This variable will hold all sorts of operation status responses
  OSStatus status;

  // Converting the NSStrings to char* variables which we will need later
  const char *labelUTF8 = [label UTF8String];
  const char *serviceUTF8 = [service UTF8String];
  const char *accountUTF8 = [account UTF8String];
  const char *descriptionUTF8 = [description UTF8String];
  const char *passwordUTF8 = [password UTF8String];

  // This variable is soon to hold the System Keychain
  SecKeychainRef keychain = NULL;

  status = SecKeychainCopyDomainDefault(kSecPreferencesDomainSystem, &keychain);
  if (status == errSecSuccess) {
    Log.debug(@"Succeeded opening System Keychain");
  } else {
    Log.error(@"Could not obtain System Keychain: %@", SecCopyErrorMessageString(status, NULL));
    return 60;
  }

  Log.debug(@"Unlocking System Keychain");
  status = SecKeychainUnlock(keychain, 0, NULL, FALSE);
  if (status == errSecSuccess) {
    Log.debug(@"Succeeded unlocking System Keychain");
  } else {
    Log.error(@"Could not unlock System Keychain: %@", SecCopyErrorMessageString(status, NULL));
    return 61;
  }

  // This variable is going to hold our new Keychain Item
  SecKeychainItemRef item = nil;

	SecAccessRef access = nil;
  status = SecAccessCreate(CFSTR("Some VPN Test"), (__bridge CFArrayRef)(self.trustedApps), &access);

  if(status == noErr) {
    Log.debug(@"Created empty Keychain access object");
  } else {
    Log.error(@"Could not unlock System Keychain: %@", SecCopyErrorMessageString(status, NULL));
    return 62;
  }

  // Putting together the configuration options
  SecKeychainAttribute attrs[] = {
    {kSecLabelItemAttr, (int)strlen(labelUTF8), (char *)labelUTF8},
    {kSecAccountItemAttr, (int)strlen(accountUTF8), (char *)accountUTF8},
    {kSecServiceItemAttr, (int)strlen(serviceUTF8), (char *)serviceUTF8},
    {kSecDescriptionItemAttr, (int)strlen(descriptionUTF8), (char *)descriptionUTF8},
  };

  SecKeychainAttributeList attributes = {sizeof(attrs) / sizeof(attrs[0]), attrs};

  status = SecKeychainItemCreateFromContent(kSecGenericPasswordItemClass, &attributes, (int)strlen(passwordUTF8), passwordUTF8, keychain, access, &item);

  if(status == noErr) {
    Log.debug(@"Successfully created Keychain Item");
  } else {
    Log.error(@"Creating Keychain item failed: %@", SecCopyErrorMessageString(status, NULL));
    return 63;
  }

  return 0;
}

+ (NSArray*) trustedApps {
  NSMutableArray *apps = [NSMutableArray array];
  SecTrustedApplicationRef app;
  OSStatus err;

  for (int i = 0; i < (sizeof(trustedAppPaths) / sizeof(*trustedAppPaths)); i++) {
    err = SecTrustedApplicationCreateFromPath(trustedAppPaths[i], &app);
    if (err == errSecSuccess) {
      //Log.debug(@"SecTrustedApplicationCreateFromPath succeeded: %@", SecCopyErrorMessageString(err, NULL));
    } else {
      Log.error(@"SecTrustedApplicationCreateFromPath failed: %@", SecCopyErrorMessageString(err, NULL));
    }

    [apps addObject:(__bridge id)app];
  }

  return apps;
}

@end
