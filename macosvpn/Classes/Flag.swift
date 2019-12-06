/*
 Copyright (c) 2014-2019 halo. https://github.com/halo/macosvpn

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

public enum Flag: String {
  /// Converts a flag to a CLI argument, e.g. `help` to `--help` and `h` to `-h`.
  var dashed: String {
    get {
      if String(describing: self).hasSuffix("Short") {
        return "-\(rawValue)"
      } else {
        return "--\(rawValue)"
      }
    }
  }

  // Global
  case Help = "help"
  case HelpShort = "h"
  case Version = "version"
  case VersionShort = "v"
  case Debug = "debug"
  case DebugShort = "d"
  case Force = "force"
  case ForceShort = "o"

  // Service Types
  case L2TP = "l2tp"
  case L2TPShort = "l"
  case Cisco = "cisco"
  case CiscoShort = "c"

  // Both L2TP and Cisco
  case Endpoint = "endpoint"
  case EndpointShort = "e"
  case Username = "username"
  case UsernameShort = "u"
  case Password = "password"
  case PasswordShort = "p"
  case SharedSecret = "sharedsecret"
  case SharedSecretShort = "s"
  case GroupName = "groupname"
  case GroupNameShort = "g"

  // L2TP-specific
  case Split = "split"
  case SplitShort = "x"
  case DisconnectSwitch = "disconnectswitch"
  case DisconnectSwitchShort = "i"
  case DisconnectLogout = "disconnectlogout"
  case DisconnectLogoutShort = "t"
}
