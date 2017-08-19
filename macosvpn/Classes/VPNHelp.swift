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

open class VPNHelp: NSObject {
  
  open class func showHelp() -> Int32 {
    DDLogDebug("Showing help...")
    
    let usage: String = Color.Wrap(styles: .bold).wrap("Usage:")
    let command: String = Color.Wrap(foreground: VPNColor.Green).wrap("sudo macosvpn create")
    let options: String = Color.Wrap(foreground: VPNColor.Pink).wrap("OPTIONS")
    
    DDLogInfo("\(usage) \(command) \(options) [OPTIONS AGAIN...]")
    DDLogInfo("")

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
    
    DDLogInfo("You can always add the \(debugFlag) option for troubleshooting.")
    DDLogInfo("The \(versionFlag) option displays the current version.")
    DDLogInfo("Add \(forceFlag) or \(forceFlagShort) to overwrite a VPN that has the same name.")
    DDLogInfo("Encapsulate arguments in \"double-quotes\" when using special characters.")
    DDLogInfo("")
    
    DDLogInfo(Color.Wrap(styles: .bold).wrap("Examples:"))
    DDLogInfo("")

    DDLogInfo(Color.Wrap(foreground: VPNColor.Blue).wrap("Creating a Cisco IPSec VPN Service"))
    DDLogInfo("\(command) \(ciscoFlag) Atlantic \(endpointFlag) atlantic.example.com \(usernameFlag) Alice \(passwordFlag) p4ssw0rd \(sharedSecretFlag) s3same \(groupnameFlag) Dreamteam")
    DDLogInfo("")
    
    DDLogInfo(Color.Wrap(foreground: VPNColor.Blue).wrap("Creating an L2TP over IPSec VPN Service"))
    DDLogInfo("\(command) \(l2tpFlag) Atlantic \(endpointFlag) atlantic.example.com \(usernameFlag) Alice \(passwordFlag) p4ssw0rd \(sharedSecretFlag) s3same")
    DDLogInfo("")

    DDLogInfo("With L2TP you can")
    DDLogInfo("  add \(splitFlag) or \(splitFlagShort) to *not* force all traffic over VPN.")
    DDLogInfo("  add \(switchFlag) or \(switchFlagShort) to disconnect when switching user accounts.")
    DDLogInfo("  add \(logoutFlag) or \(logoutFlagShort) to disconnect when user logs out.")
    DDLogInfo("")
    DDLogInfo("Note: The examples below assume Cisco, but they are analogous to the L2TP command.")

    DDLogInfo("")
    DDLogInfo(Color.Wrap(foreground: VPNColor.Blue).wrap("The same command as above but shorter"))
    DDLogInfo("\(command) \(ciscoFlagShort) Atlantic \(endpointFlagShort) atlantic.example.com \(usernameFlagShort) Alice \(passwordFlagShort) p4ssw0rd \(sharedSecretFlagShort) s3same \(groupnameFlagShort) Dreamteam")
    DDLogInfo("")

    DDLogInfo(Color.Wrap(foreground: VPNColor.Blue).wrap("The same command as short as possible"))
    DDLogInfo("\(command) \(allShortCiscoFlags) Atlantic atlantic.example.com Alice p4ssw0rd s3same Dreamteam")
    DDLogInfo("")

    DDLogInfo(Color.Wrap(foreground: VPNColor.Blue).wrap("Repeat arguments to create multiple VPNs"))
    DDLogInfo("\(command) \(allShortCiscoFlags) Atlantic atlantic.example.com Alice p4ssw0rd s3same Dreamteam \\")
    DDLogInfo("                     \(allShortCiscoFlags) Northpole northpole.example.com Bob s3cret pr1v4te Spaceteam")
    DDLogInfo("")
    
    DDLogInfo("This application is released under the MIT license.")
    DDLogInfo("Copyright (c) 2014-\(self.currentYear()) halo.")
    DDLogInfo(Color.Wrap(foreground: VPNColor.Brown).wrap("https://github.com/halo/macosvpn"))
    
    // Displaying the help should not be interpreted as a success.
    // That's why we exit with a non-zero status code.
    return VPNExitCode.ShowingHelp
  }
  
  open class func showVersion() -> Int32 {
    DDLogDebug("Showing version...")
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
