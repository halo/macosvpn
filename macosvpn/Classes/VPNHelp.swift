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

open class VPNHelp: NSObject {
  
  open class func showHelp() -> Int32 {
    Log.debug("Showing help...")
    
    let usage: String = Color.Wrap(styles: .bold).wrap("Usage:")
    let createCommand: String = Color.Wrap(foreground: VPNColor.Green).wrap("sudo macosvpn create")
    let createOptions: String = Color.Wrap(foreground: VPNColor.Pink).wrap("OPTIONS")

    let deleteCommand: String = Color.Wrap(foreground: VPNColor.Red).wrap("macosvpn delete")
    let deleteOptions: String = Color.Wrap(foreground: VPNColor.Pink).wrap("--name MyVPN")

    Log.info("\(usage) \(createCommand) \(createOptions) [OPTIONS AGAIN...]")
    Log.info("            \(deleteCommand) \(deleteOptions) [--name AnotherVPN]")
    Log.info("")

    let debugFlag: String = Color.Wrap(foreground: VPNColor.Pink).wrap("--debug")
    let versionFlag: String = Color.Wrap(foreground: VPNColor.Pink).wrap("--version")
    let ciscoFlag: String = Color.Wrap(foreground: VPNColor.Pink).wrap("--cisco")
    let ciscoFlagShort: String = Color.Wrap(foreground: VPNColor.Pink).wrap("-c")
    let l2tpFlag: String = Color.Wrap(foreground: VPNColor.Pink).wrap("--l2tp")
    let endpointFlag: String = Color.Wrap(foreground: VPNColor.Pink).wrap("--endpoint")
    let endpointFlagShort: String = Color.Wrap(foreground: VPNColor.Pink).wrap("-e")
    let usernameFlag: String = Color.Wrap(foreground: VPNColor.Pink).wrap("--username")
    let usernameFlagShort: String = Color.Wrap(foreground: VPNColor.Pink).wrap("-u")
    let passwordFlag: String = Color.Wrap(foreground: VPNColor.Pink).wrap("--password")
    let passwordFlagShort: String = Color.Wrap(foreground: VPNColor.Pink).wrap("-p")
    let sharedSecretFlag: String = Color.Wrap(foreground: VPNColor.Pink).wrap("--shared-secret")
    let sharedSecretFlagShort: String = Color.Wrap(foreground: VPNColor.Pink).wrap("-s")
    let groupnameFlag: String = Color.Wrap(foreground: VPNColor.Pink).wrap("--groupname")
    let groupnameFlagShort: String = Color.Wrap(foreground: VPNColor.Pink).wrap("-g")
    let splitFlag: String = Color.Wrap(foreground: VPNColor.Pink).wrap("--split")
    let splitFlagShort: String = Color.Wrap(foreground: VPNColor.Pink).wrap("-x")
    let switchFlag: String = Color.Wrap(foreground: VPNColor.Pink).wrap("--disconnectswitch")
    let switchFlagShort: String = Color.Wrap(foreground: VPNColor.Pink).wrap("-i")
    let logoutFlag: String = Color.Wrap(foreground: VPNColor.Pink).wrap("--disconnectlogout")
    let logoutFlagShort: String = Color.Wrap(foreground: VPNColor.Pink).wrap("-t")
    let forceFlag: String = Color.Wrap(foreground: VPNColor.Pink).wrap("--force")
    let forceFlagShort: String = Color.Wrap(foreground: VPNColor.Pink).wrap("-o")
    let allShortCiscoFlags: String = Color.Wrap(foreground: VPNColor.Pink).wrap("-ceupsg")
    let nameFlag: String = Color.Wrap(foreground: VPNColor.Pink).wrap("-name")

    Log.info("You can always add the \(debugFlag) option for troubleshooting.")
    Log.info("The \(versionFlag) option displays the current version.")
    Log.info("Add \(forceFlag) or \(forceFlagShort) to overwrite a VPN that has the same name.")
    Log.info("Encapsulate arguments in \"double-quotes\" when using special characters.")
    Log.info("")
    
    Log.info(Color.Wrap(styles: .bold).wrap("Examples:"))
    Log.info("")

    Log.info(Color.Wrap(foreground: VPNColor.Blue).wrap("Creating a Cisco IPSec VPN Service"))
    Log.info("\(createCommand) \(ciscoFlag) Atlantic \(endpointFlag) atlantic.example.com \(usernameFlag) Alice \(passwordFlag) p4ssw0rd \(sharedSecretFlag) s3same \(groupnameFlag) Dreamteam")
    Log.info("")
    
    Log.info(Color.Wrap(foreground: VPNColor.Blue).wrap("Creating an L2TP over IPSec VPN Service"))
    Log.info("\(createCommand) \(l2tpFlag) Atlantic \(endpointFlag) atlantic.example.com \(usernameFlag) Alice \(passwordFlag) p4ssw0rd \(sharedSecretFlag) s3same")
    Log.info("")

    Log.info("With L2TP you can")
    Log.info("  add \(splitFlag) or \(splitFlagShort) to *not* force all traffic over VPN.")
    Log.info("  add \(switchFlag) or \(switchFlagShort) to disconnect when switching user accounts.")
    Log.info("  add \(logoutFlag) or \(logoutFlagShort) to disconnect when user logs out.")
    Log.info("")
    Log.info("Note: The examples below assume Cisco, but they are analogous to the L2TP command.")

    Log.info("")
    Log.info(Color.Wrap(foreground: VPNColor.Blue).wrap("The same command as above but shorter"))
    Log.info("\(createCommand) \(ciscoFlagShort) Atlantic \(endpointFlagShort) atlantic.example.com \(usernameFlagShort) Alice \(passwordFlagShort) p4ssw0rd \(sharedSecretFlagShort) s3same \(groupnameFlagShort) Dreamteam")
    Log.info("")

    Log.info(Color.Wrap(foreground: VPNColor.Blue).wrap("The same command as short as possible"))
    Log.info("\(createCommand) \(allShortCiscoFlags) Atlantic atlantic.example.com Alice p4ssw0rd s3same Dreamteam")
    Log.info("")

    Log.info(Color.Wrap(foreground: VPNColor.Blue).wrap("Repeat arguments to create multiple VPNs"))
    Log.info("\(createCommand) \(allShortCiscoFlags) Atlantic atlantic.example.com Alice p4ssw0rd s3same Dreamteam \\")
    Log.info("                     \(allShortCiscoFlags) Northpole northpole.example.com Bob s3cret pr1v4te Spaceteam")
    Log.info("")

    Log.info(Color.Wrap(foreground: VPNColor.Blue).wrap("Delete any VPN Service by name"))
    Log.info("\(deleteCommand) \(nameFlag) Atlantic")
    Log.info("")

    Log.info("This application is released under the MIT license.")
    Log.info("Copyright (c) 2014-\(self.currentYear()) halo.")
    Log.info(Color.Wrap(foreground: VPNColor.Brown).wrap("https://github.com/halo/macosvpn"))
    
    // Displaying the help should not be interpreted as a success.
    // That's why we exit with a non-zero status code.
    return VPNExitCode.ShowingHelp
  }
  
  open class func showVersion() -> Int32 {
    Log.debug("Showing version...")
    print(self.currentVersion());
    return VPNExitCode.ShowingVersion
  }
  
  fileprivate class func currentYear() -> String {
    let formatter: DateFormatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter.string(from: Date())
  }
  
  fileprivate class func currentVersion() -> String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
  }
  
}
