/*
Copyright (c) 2014-2016 halo. https://github.com/halo/macosvpn

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

public enum Help {
  public static func showHelp() {
    Log.debug("Showing help...")

    // USAGE
    
    let usage = Colorize.boldUnderlined("Usage:")
    let createCommand = Colorize.green("sudo macosvpn \(Options.Command.create)")
    let deleteCommand = Colorize.red("sudo macosvpn \(Options.Command.delete)")
    let options = Colorize.pink("OPTIONS")

    Log.info("\(usage) \(createCommand) \(options)")
    Log.info("       \(deleteCommand) \(options)")
    Log.info("")

    // GENERAL OPTIONS

    let generalOptions = Colorize.boldUnderlined("General Options:")
    let debugFlag = Colorize.pink(Flag.Debug.dashed)
    let debugFlagShort = Colorize.pink(Flag.DebugShort.dashed)
    let helpFlag = Colorize.pink(Flag.Help.dashed)
    let helpFlagShort = Colorize.pink(Flag.HelpShort.dashed)
    let versionFlag = Colorize.pink(Flag.Version.dashed)
    let versionFlagShort = Colorize.pink(Flag.VersionShort.dashed)
    let usernameFlag = Colorize.pink(Flag.Username.dashed)
    let forceFlag = Colorize.pink(Flag.Force.dashed)
    let forceFlagShort = Colorize.pink(Flag.ForceShort.dashed)

    Log.info(generalOptions)
    Log.info("")
    Log.info("The \(versionFlag) or \(versionFlagShort) option displays the current version.")
    Log.info("Adding \(helpFlag) or \(helpFlagShort) shows this help.")
    Log.info("You can always add the \(debugFlag) or \(debugFlagShort) option for troubleshooting.")
    Log.info("Add \(forceFlag) or \(forceFlagShort) to overwrite an existing VPN with the same name.")
    Log.info("Encapsulate arguments in \"double-quotes\" when using special characters, e.g. \(usernameFlag) \"Noël\".")
    Log.info("")

    // CREATE EXAMPLES

    let ciscoFlag = Colorize.pink(Flag.Cisco.dashed)
    let ciscoFlagShort = Colorize.pink(Flag.CiscoShort.dashed)
    let l2tpFlag = Colorize.pink(Flag.L2TP.dashed)
    let l2tpFlagShort = Colorize.pink(Flag.L2TPShort.dashed)
    let endpointFlag = Colorize.pink(Flag.Endpoint.dashed)
    let endpointFlagShort = Colorize.pink(Flag.EndpointShort.dashed)
    let usernameFlagShort = Colorize.pink(Flag.UsernameShort.dashed)
    let passwordFlag = Colorize.pink(Flag.Password.dashed)
    let passwordFlagShort = Colorize.pink(Flag.PasswordShort.dashed)
    let sharedSecretFlag = Colorize.pink(Flag.SharedSecret.dashed)
    let sharedSecretFlagShort = Colorize.pink(Flag.SharedSecretShort.dashed)
    let groupnameFlag = Colorize.pink(Flag.GroupName.dashed)
    let groupnameFlagShort = Colorize.pink(Flag.GroupNameShort.dashed)
    let splitFlag = Colorize.pink(Flag.Split.dashed)
    let splitFlagShort = Colorize.pink(Flag.SplitShort.dashed)
    let switchFlag = Colorize.pink(Flag.DisconnectSwitch.dashed)
    let switchFlagShort = Colorize.pink(Flag.DisconnectSwitchShort.dashed)
    let logoutFlag = Colorize.pink(Flag.DisconnectLogout.dashed)
    let logoutFlagShort = Colorize.pink(Flag.DisconnectLogoutShort.dashed)
    let nameFlag = Colorize.pink(Flag.Name.dashed)
    let nameFlagShort = Colorize.pink(Flag.NameShort.dashed)
    let allFlag = Colorize.pink(Flag.All.dashed)
    let allFlagShort = Colorize.pink(Flag.AllShort.dashed)

    Log.info(Colorize.boldUnderlined("Examples:"))
    Log.info("")

    Log.info(Colorize.blue("Create a Cisco IPSec VPN service"))
    Log.info("\(createCommand) \(ciscoFlag) Atlantic \(endpointFlag) example.com \(usernameFlag) Alice \(passwordFlag) p4ssw0rd \(sharedSecretFlag) s3same \(groupnameFlag) Dreamteam")
    Log.info("\(createCommand) \(ciscoFlagShort) Atlantic \(endpointFlagShort) example.com \(usernameFlagShort) Alice \(passwordFlagShort) p4ssw0rd \(sharedSecretFlagShort) s3same \(groupnameFlagShort) Dreamteam")
    Log.info("")
    
    Log.info(Colorize.blue("Create an L2TP over IPSec VPN service"))
    Log.info("\(createCommand) \(l2tpFlag) Atlantic \(endpointFlag) example.com \(usernameFlag) Alice \(passwordFlag) p4ssw0rd \(sharedSecretFlag) s3same \(groupnameFlag) Dreamteam")
    Log.info("\(createCommand) \(l2tpFlagShort) Atlantic \(endpointFlagShort) example.com \(usernameFlagShort) Alice \(passwordFlagShort) p4ssw0rd \(sharedSecretFlagShort) s3same \(groupnameFlagShort) Dreamteam")
    Log.info("")

    Log.info(Colorize.blue("Create multiple services"))
    Log.info("\(createCommand) \(ciscoFlagShort) Atlantic \(endpointFlagShort) atlantic.example.com \(usernameFlagShort) Alice \(passwordFlagShort) p4ssw0rd \\")
    Log.info("                     \(l2tpFlagShort) Pacific \(endpointFlagShort) pacific.example.com \(usernameFlagShort) Bob \(passwordFlagShort) s3same ")
    Log.info("")

    Log.info("With L2TP you can")
    Log.info("  add \(splitFlag) or \(splitFlagShort) to *not* force all traffic over VPN.")
    Log.info("  add \(switchFlag) or \(switchFlagShort) to disconnect when switching user accounts.")
    Log.info("  add \(logoutFlag) or \(logoutFlagShort) to disconnect when user logs out.")
    Log.info("")

    Log.info(Colorize.blue("Delete L2TP and/or Cisco VPN services"))
    Log.info("\(deleteCommand) \(nameFlag) Atlantic")
    Log.info("\(deleteCommand) \(nameFlagShort) Atlantic \(nameFlagShort) Pacific")
    Log.info("\(deleteCommand) \(allFlag)")
    Log.info("\(deleteCommand) \(allFlagShort)")
    Log.info("")

    Log.info("This application is released under the MIT license.")
    Log.info("Copyright (c) 2014-\(self.currentYear()) halo.")
    Log.info(Colorize.brown("https://github.com/halo/macosvpn"))
  }
  
  public static func showVersion() {
    Log.debug("Showing version...")
    print(self.currentVersion());
  }

  fileprivate static func currentYear() -> String {
    let formatter: DateFormatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter.string(from: Date())
  }
  
  fileprivate static func currentVersion() -> String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
  }

}
