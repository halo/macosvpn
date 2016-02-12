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

#import "VPNLogFormatter.h"

@implementation VPNLogFormatter

- (NSString*) formatLogMessage:(DDLogMessage *)logMessage {
  if (logMessage->_flag == DDLogFlagInfo) return [NSString stringWithFormat:@"  %@", logMessage->_message];

  /*
  // Currently we don't print the level name
 
  NSString *logLevel;
  switch (logMessage->logFlag) {
    case LOG_FLAG_ERROR : logLevel = @"ERROR"; break;
    case LOG_FLAG_WARN  : logLevel = @" WARN"; break;
    case LOG_FLAG_INFO  : logLevel = @" INFO"; break;
    case LOG_FLAG_DEBUG : logLevel = @"DEBUG"; break;
    default             : logLevel = @"INTRN"; break;
  }
  */

  NSUInteger colorCode;
  switch (logMessage->_flag) {
    case DDLogFlagError   : colorCode = 31; break;
    case DDLogFlagWarning : colorCode = 33; break;
    case DDLogFlagDebug   : colorCode =  2; break;
    default               : colorCode =  0; break;
  }
                                   
  return [NSString stringWithFormat:@"  \033[%lum%@\033[0m\033[0m", (unsigned long)colorCode, logMessage->_message];
}

@end
