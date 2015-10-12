/*
 Copyright (c) 2014 funkensturm. https://github.com/halo/macosvpn

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

#import "VPNServiceConfig.h"

#import <SystemConfiguration/SystemConfiguration.h>

@implementation VPNServiceConfig

@synthesize type, name, endpointPrefix, endpointSuffix, username, password, sharedSecret, localIdentifier;
@synthesize endpoint = _endpoint;

- (void) setEndpoint:(NSString *)newEndpoint {
  _endpoint = newEndpoint;
}

- (NSString*) endpoint {
  if (_endpoint) return _endpoint;
  if ((!endpointPrefix && !endpointSuffix) || ([endpointPrefix isEqualToString:@""] && [endpointSuffix isEqualToString:@""])) return NULL;
  return [NSString stringWithFormat:@"%@%@", endpointPrefix, endpointSuffix];
}

- (BOOL) is:(NSUInteger)aType {
  return self.type == aType;
}

- (NSString*) humanType {
  switch(self.type) {
    case VPNServiceL2TPOverIPSec : return @"L2TP over IPSec"; break;
    case VPNServiceCiscoIPSec    : return @"Cisco IPSec"; break;
    default                      : return @"Unknown"; break;
  }
}

- (NSString*) description {
  return [NSString stringWithFormat:@"<[%@] name=%@ endpointPrefix=%@ endpoint=%@ endpointSuffix=%@ username=%@ password=%@ sharedSecret=%@ localIdentifier=%@>", self.humanType, self.name, self.endpointPrefix, self.endpoint, self.endpointSuffix, self.username, self.password, self.sharedSecret, self.localIdentifier];
}

- (CFDictionaryRef) L2TPPPPConfig {
  CFStringRef keys[4] = { NULL, NULL, NULL, NULL };
  CFStringRef vals[4] = { NULL, NULL, NULL, NULL };
  CFIndex count = 0;

  keys[count] = kSCPropNetPPPCommRemoteAddress;
  vals[count++] = (__bridge CFStringRef)self.endpoint;

  keys[count] = kSCPropNetPPPAuthName;
  vals[count++] = (__bridge CFStringRef)self.username;

  keys[count] = kSCPropNetPPPAuthPassword;
  vals[count++] = (__bridge CFStringRef)self.serviceID;

  keys[count] = kSCPropNetPPPAuthPasswordEncryption;
  vals[count++] = kSCValNetPPPAuthPasswordEncryptionKeychain;

  return CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&vals, count, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
}

- (CFDictionaryRef) L2TPIPSecConfig {
  CFStringRef keys[3] = { NULL, NULL, NULL };
  CFStringRef vals[3] = { NULL, NULL, NULL };
  CFIndex count = 0;

  keys[count] = kSCPropNetIPSecAuthenticationMethod;
  vals[count++] = kSCValNetIPSecAuthenticationMethodSharedSecret;

  keys[count] = kSCPropNetIPSecSharedSecretEncryption;
  vals[count++] = kSCValNetIPSecSharedSecretEncryptionKeychain;

  keys[count] = kSCPropNetIPSecSharedSecret;
  vals[count++] = (__bridge CFStringRef)[NSString stringWithFormat:@"%@.SS", self.serviceID];

  return CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&vals, count, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
}

- (CFDictionaryRef) L2TPIPv4Config {
  CFStringRef keys[5] = { NULL, NULL, NULL, NULL, NULL };
  CFStringRef vals[5] = { NULL, NULL, NULL, NULL, NULL };
  CFIndex count = 0;

  keys[count] = kSCPropNetIPv4ConfigMethod;
  vals[count++] = kSCValNetIPv4ConfigMethodPPP;

  int one = 1;
  keys[count] = kSCPropNetOverridePrimary;

  // X-Code warns on this (CFString VS. CFNumber), but it should not matter, CFNumber is the correct type I think, as you can verify in the resulting /Library/Preferences/SystemConfiguration/preferences.plist file.
  // See also https://developer.apple.com/library/prerelease/ios/documentation/CoreFoundation/Conceptual/CFPropertyLists/Articles/Numbers.html
  #pragma clang diagnostic ignored "-Wincompatible-pointer-types"
  vals[count++] = CFNumberCreate(NULL, kCFNumberIntType, &one);
  #pragma clang diagnostic pop

  return CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&vals, count, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
}

- (CFDictionaryRef) ciscoConfig {
  CFStringRef keys[9] = { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL };
  CFStringRef vals[9] = { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL };
  CFIndex count = 0;

  keys[count]   = kSCPropNetIPSecAuthenticationMethod;
  vals[count++] = kSCValNetIPSecAuthenticationMethodSharedSecret;

  keys[count]   = kSCPropNetIPSecSharedSecret;
  vals[count++] = (__bridge CFStringRef)[NSString stringWithFormat:@"%@.SS", self.serviceID];
  
  keys[count]   = kSCPropNetIPSecSharedSecretEncryption;
  vals[count++] = kSCValNetIPSecSharedSecretEncryptionKeychain;
  
  keys[count]   = kSCPropNetIPSecRemoteAddress;
  vals[count++] = (__bridge CFStringRef)self.endpoint;

  keys[count]   = kSCPropNetIPSecXAuthName;
  vals[count++] = (__bridge CFStringRef)self.username;
  
  keys[count]   = kSCPropNetIPSecXAuthPassword;
  vals[count++] = (__bridge CFStringRef)self.serviceID;

  keys[count]   = kSCPropNetIPSecXAuthPasswordEncryption;
  vals[count++] = kSCValNetIPSecXAuthPasswordEncryptionKeychain;

  keys[count]   = kSCPropNetIPSecLocalIdentifier;
  vals[count++] = (__bridge CFStringRef)self.localIdentifier;
    
  keys[count]    = kSCPropNetIPSecLocalIdentifierType;
  vals[count++]  = kSCValNetIPSecLocalIdentifierTypeKeyID;

  return CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&vals, count, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
}

@end
