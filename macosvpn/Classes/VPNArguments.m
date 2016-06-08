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

// Vendor Dependencies
#import "FSArguments.h"

// Local Dependencies
#import "VPNArguments.h"
#import "VPNServiceConfig.h"

@implementation VPNArguments

// Public Class Methods

+ (void) setLogLevel {
  if ([self.package countOfSignature:self.debugSig]) {
    [VPNLogger setup:DDLogLevelDebug];
    DDLogDebug(@"");
    DDLogDebug(@"You are running in debug mode");
  } else {
    [VPNLogger setup:DDLogLevelInfo];
  }
}

+ (BOOL) helpRequested {
  return [self.package booleanValueForSignature: self.helpSig] || [self command] == VPNCommandNone;
}

+ (BOOL) versionRequested {
  return [self.package booleanValueForSignature: self.versionSig];
}

+ (BOOL) forceRequested {
  return [self.package booleanValueForSignature: self.forceSig];
}

+ (NSUInteger) command {
  if ([[self.package unknownSwitches] count] > 0) DDLogDebug(@"Unknown arguments: %@", [[self.package unknownSwitches] componentsJoinedByString:@" | "]);
  if ([[self.package uncapturedValues] count] > 0) DDLogDebug(@"Uncaptured argument values: %@", [[self.package uncapturedValues] componentsJoinedByString:@" | "]);
  
  if ([self.package countOfSignature:self.createCommandSig] == VPNCommandCreate) {
    return VPNCommandCreate;
  } else {
    return VPNCommandNone;
  }
}

+ (NSArray*) serviceConfigs {
  NSArray *l2tpConfigs = [self serviceConfigsForType:VPNServiceL2TPOverIPSec andSignature:self.l2tpSig];
  NSArray *ciscoConfigs = [self serviceConfigsForType:VPNServiceCiscoIPSec andSignature:self.ciscoSig];

  return [l2tpConfigs arrayByAddingObjectsFromArray:ciscoConfigs];
}

// Internal Class Methods

+(NSArray*) serviceConfigsForType:(NSUInteger)type andSignature:(FSArgumentSignature*)signature {
  NSUInteger count = [self.package countOfSignature:signature];
  NSMutableArray *configs = [NSMutableArray arrayWithCapacity:count];
  
  VPNServiceConfig *config;
  for (NSUInteger i = 0; i < count; i++) {
    config = [VPNServiceConfig new];
    config.type = type;
    config.name = [self.package objectAtIndex:i forSignature:signature];

    config.endpointPrefix = [self extractArgumentForSignature:self.endpointPrefixSig withFallbackSignature:self.defaultEndpointPrefixSig atIndex:i];
    config.endpointSuffix = [self extractArgumentForSignature:self.endpointSuffixSig withFallbackSignature:self.defaultEndpointSuffixSig atIndex:i];

    NSString *endpoint = [self extractArgumentForSignature:self.endpointSig withFallbackSignature:self.defaultEndpointSig atIndex:i];
    if (endpoint) config.endpoint = endpoint;
    if (!config.endpoint) {
      DDLogError(@"Error: You did not provide an endpoint for service <%@>", config.name);
      DDLogDebug(@"%@", config);
      exit(50);
    }

    config.username = [self extractArgumentForSignature:self.usernameSig withFallbackSignature:self.defaultUsernameSig atIndex:i];
    if (!config.username) DDLogWarn(@"Warning: You did not provide a username for service <%@>", config.name);

    config.password = [self extractArgumentForSignature:self.passwordSig withFallbackSignature:self.defaultPasswordSig atIndex:i];
    if (!config.password) DDLogWarn(@"Warning: You did not provide a password for service <%@>", config.name);
    
    config.sharedSecret = [self extractArgumentForSignature:self.sharedSecretSig withFallbackSignature:self.defaultSharedSecretSig atIndex:i];
    if (!config.sharedSecret) DDLogWarn(@"Warning: You did not provide a shared secret for service <%@>", config.name);

    config.localIdentifier = [self extractArgumentForSignature:self.localIdentifierSig withFallbackSignature:self.defaultLocalIdentifierSig atIndex:i];
    //if (!config.localIdentifier) DDLogWarn(@"Warning: You did not provide a group name for service <%@>", config.name);

    config.enableSplitTunnel = [self.package countOfSignature:self.splitTunnelSig] > 0;
      
    [configs addObject:config];
  }
  return configs;
}

+ (NSString*) extractArgumentForSignature:(FSArgumentSignature*)signature withFallbackSignature:(FSArgumentSignature*)fallbackSignature atIndex:(NSUInteger)index {
  if ([self.package countOfSignature:fallbackSignature] == 1) {
    return [self.package firstObjectForSignature:fallbackSignature];
  } else if ([self.package countOfSignature:signature] >= index + 1) {
    return [self.package objectAtIndex:index forSignature:signature];
  } else {
    return NULL;
  }
}

// Internal: Subcommand Arguments

+ (FSArgumentSignature*) createCommandSig {
  FSArgumentSignature *command = [FSArgumentSignature argumentSignatureWithFormat:@"[create]"];

  NSSet *createSignatures = [NSSet setWithObjects:
    self.l2tpSig, self.ciscoSig,
    self.defaultEndpointPrefixSig, self.endpointPrefixSig,
    self.defaultEndpointSig, self.endpointSig,
    self.defaultEndpointSuffixSig, self.endpointSuffixSig,
    self.defaultUsernameSig, self.usernameSig,
    self.defaultPasswordSig, self.passwordSig,
    self.defaultSharedSecretSig, self.sharedSecretSig,
    self.defaultLocalIdentifierSig, self.localIdentifierSig,
    self.splitTunnelSig,
  nil];

  [command setInjectedSignatures:createSignatures];
  return command;
}

// Internal: default Argument Flags

+ (FSArgumentSignature*) helpSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-h --help help]"];
}

+ (FSArgumentSignature*) debugSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-d --debug debug]"];
}

+ (FSArgumentSignature*) versionSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-v --version version]"];
}

// Internal: Interface Arguments

+ (FSArgumentSignature*) l2tpSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-l --l2tp l2tp]={1,}"];
}

+ (FSArgumentSignature*) ciscoSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-c --cisco cisco]={1,}"];
}

// Internal: Default Interface Configuration Arguments

+ (FSArgumentSignature*) splitTunnelSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-x --split split]"];
}

+ (FSArgumentSignature*) defaultEndpointPrefixSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-i --defaultendpointprefix defaultendpointprefix]="];
}

+ (FSArgumentSignature*) defaultEndpointSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-n --defaultendpoint defaultendpoint]="];
}

+ (FSArgumentSignature*) defaultEndpointSuffixSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-k --defaultendpointsuffix defaultendpointsuffix]="];
}

+ (FSArgumentSignature*) defaultUsernameSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-m --defaultusername defaultusername]="];
}

+ (FSArgumentSignature*) defaultPasswordSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-a --defaultpassword defaultpassword]="];
}

+ (FSArgumentSignature*) defaultSharedSecretSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-t --defaultsharedsecret defaultsharedsecret]="];
}

+ (FSArgumentSignature*) defaultLocalIdentifierSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-j --defaultgroupname defaultgroupname]="];
}

// Internal: Individual Interface Configuration Arguments

+ (FSArgumentSignature*) endpointPrefixSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-f --endpointprefix endpointprefix]={1,}"];
}

+ (FSArgumentSignature*) endpointSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-e --endpoint endpoint]={1,}"];
}

+ (FSArgumentSignature*) endpointSuffixSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-o --endpointsuffix endpointsuffix]={1,}"];
}

+ (FSArgumentSignature*) usernameSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-u --username username]={1,}"];
}

+ (FSArgumentSignature*) passwordSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-p --password password]={1,}"];
}

+ (FSArgumentSignature*) sharedSecretSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-s --sharedsecret sharedsecret]={1,}"];
}

+ (FSArgumentSignature*) localIdentifierSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-g --groupname groupname]={1,}"];
}

+ (FSArgumentSignature*) forceSig {
  return [FSArgumentSignature argumentSignatureWithFormat:@"[-o --force force]"];
}

+ (NSArray*) signatures {
  return @[
    self.helpSig,
    self.debugSig,
    self.versionSig,
    self.forceSig,
    self.createCommandSig
  ];
}

// Wrapping up all valid argument signatures
+ (FSArgumentPackage*) package {
  return [[NSProcessInfo processInfo] fsargs_parseArgumentsWithSignatures:self.signatures];
}

@end
