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

#import "VPNHelp.h"
#import "VPNArguments.h"

@implementation VPNHelp

+ (int) showHelp {
  DDLogDebug(@"Showing help...");

  DDLogInfo(@"Usage: macosvpn [ACTION] [OPTIONS] [SAME OPTIONS AGAIN...]");

  DDLogInfo(@"");
  DDLogInfo(@"\033[2mYou can add the\033[0m\033[0m --debug \033[2m option for troubleshooting.\033[0m\033[0m");
  DDLogInfo(@"");
  DDLogInfo(@"Examples:");
  DDLogInfo(@"");
  DDLogInfo(@" \033[2m Creating a single L2TP over IPSec VPN Service \033[0m\033[0m");
  DDLogInfo(@"  macosvpn create --l2tp Atlantic --endpoint atlantic.example.com --username Alice --password p4ssw0rd --shared-secret s3same");
  DDLogInfo(@"");
  DDLogInfo(@" \033[2m The same command but shorter \033[0m\033[0m");
  DDLogInfo(@"  macosvpn create l2tp Atlantic endpoint atlantic.example.com username Alice password p4ssw0rd shared-secret s3same");
  DDLogInfo(@"");
  DDLogInfo(@" \033[2m The same command even shorter \033[0m\033[0m");
  DDLogInfo(@"  macosvpn create -l Atlantic -e atlantic.example.com -u Alice -p p4ssw0rd -s s3same");
  DDLogInfo(@"");
  DDLogInfo(@" \033[2m The same command as short as possible \033[0m\033[0m");
  DDLogInfo(@"  macosvpn create -leups Atlantic atlantic.example.com Alice p4ssw0rd s3same \033[0m\033[0m");
  DDLogInfo(@"");
  DDLogInfo(@" \033[2m Repeat the arguments for creating multiple Services at once (no matter which short version you use :) \033[0m\033[0m");
  DDLogInfo(@"  macosvpn create -leups Atlantic atlantic.example.com Alice p4ssw0rd s3same \\");
  DDLogInfo(@"                  -leups Northpole northpole.example.com Bob s3cret pr1v4te");
  DDLogInfo(@"");
  DDLogInfo(@" \033[2m Assign default values which will be applied to every service \033[0m\033[0m");
  DDLogInfo(@"  macosvpn create --default-username Alice --default-password p4ssw0rd --default-endpoint-suffix .example.com \\");
  DDLogInfo(@"                  --l2tp Australia --endpoint-prefix australia --shared-secret s3same \\");
  DDLogInfo(@"                  --l2tp Island --endpoint-prefix island --shared-secret letme1n");
  DDLogInfo(@"");

  DDLogInfo(@" \033[2m This application is released under the MIT license. \033[0m\033[0m");
  DDLogInfo(@" \033[2m Copyright (c) 2014 funkensturm. See https://github.com/halo/macosvpn \033[0m\033[0m");

  // Displaying the help should not be interpreted as a success.
  // That's why we exit with a non-zero status code.
  return 99;
}

+ (int) showVersion {
  DDLogDebug(@"Showing version...");

  NSBundle *bundle = [NSBundle mainBundle];
  NSString *version = [bundle objectForInfoDictionaryKey: (NSString*) kCFBundleVersionKey];
  printf("%s", [version UTF8String]);
  printf("%s", [@"\n" UTF8String]);

  return 98;
}

@end
