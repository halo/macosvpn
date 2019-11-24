/*
 Copyright (c) 2019 halo. https://github.com/halo/macosvpn
 
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

import Foundation
import Moderator

open class Runtime: NSObject {
  
  public enum Command: String {
    case create
    case delete
    case version
    case help
  }
  
  // Class Shortcuts
  
  //public static var instance = Runtime()
  //
  //public static var command: Command = Command.help
  
  //public static var command: Command {
  //  self.instance.command
  //}
  
  //public static var forceRequested: Bool {
  //  self.instance.forceRequested
  //}
  
    
  //private var arguments = Array(CommandLine.arguments.dropFirst())
  
  // Flags
  
  public var command: Command = .help
  
  //private var helpRequested = true
  //private var versionRequested = false
  public var forceRequested = false
  
  //private var helpRequested = FutureValue<Bool>()
  //private var versionRequested = FutureValue<Bool>()
  //private var forceRequested = FutureValue<Bool>()
  
  // Parsing
}
