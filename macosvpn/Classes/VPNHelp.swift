public class VPNHelp : NSObject {
  
  public class func showHelp() -> Int32 {
    DDLogDebug("Showing help...")
    
    DDLogInfo("Usage: macosvpn [ACTION] [OPTIONS] [SAME OPTIONS AGAIN...]")
    DDLogInfo("")
    DDLogInfo("\033[2mYou can add the\033[0m\033[0m --debug \033[2m option for troubleshooting.\033[0m\033[0m")
    DDLogInfo("")
    DDLogInfo("Examples:")
    DDLogInfo("")
    DDLogInfo(" \033[2m Creating a single L2TP over IPSec VPN Service \033[0m\033[0m")
    DDLogInfo("  sudo macosvpn create --l2tp Atlantic --endpoint atlantic.example.com --username Alice --password p4ssw0rd --shared-secret s3same")
    DDLogInfo("")
    DDLogInfo("  \033[2mNote: for Cisco IPSec you would use\033[0m\033[0m --cisco \033[2minstead of\033[0m --l2tp\033[2m and\033[0m -c\033[2m instead of\033[0m -l\033[2m")
    DDLogInfo("       \033[2m The Cisco group name can be specified with\033[0m --groupname EasyVPN\033[2m or just\033[0m -g EasyVPN\033[2m")
    DDLogInfo("")
    DDLogInfo("  \033[2mNote: for L2TP, you can add the\033[0m\033[0m --split \033[2mflat to *not* force all traffic over VPN.")
    DDLogInfo("")
    DDLogInfo(" \033[2m The same command but shorter \033[0m\033[0m")
    DDLogInfo("  sudo macosvpn create l2tp Atlantic endpoint atlantic.example.com username Alice password p4ssw0rd shared-secret s3same")
    DDLogInfo("")
    DDLogInfo(" \033[2m The same command even shorter \033[0m\033[0m")
    DDLogInfo("  sudo macosvpn create -l Atlantic -e atlantic.example.com -u Alice -p p4ssw0rd -s s3same")
    DDLogInfo("")
    DDLogInfo(" \033[2m The same command as short as possible \033[0m\033[0m")
    DDLogInfo("  sudo macosvpn create -leups Atlantic atlantic.example.com Alice p4ssw0rd s3same \033[0m\033[0m")
    DDLogInfo("")
    DDLogInfo(" \033[2m Repeat the arguments for creating multiple Services at once (no matter which short version you use :) \033[0m\033[0m")
    DDLogInfo("  sudo macosvpn create -leups Atlantic atlantic.example.com Alice p4ssw0rd s3same \\")
    DDLogInfo("                       -leups Northpole northpole.example.com Bob s3cret pr1v4te")
    DDLogInfo("")
    DDLogInfo(" \033[2m Assign default values which will be applied to every service \033[0m\033[0m")
    DDLogInfo("  sudo macosvpn create --default-username Alice --default-password p4ssw0rd --default-endpoint-suffix .example.com \\")
    DDLogInfo("                       --l2tp Australia --endpoint-prefix australia --shared-secret s3same \\")
    DDLogInfo("                       --l2tp Island --endpoint-prefix island --shared-secret letme1n")
    DDLogInfo("")
    DDLogInfo(" \033[2m If Shared Secret includes nonalphanumeric symbols use double quote for entire shared secret  ")
    DDLogInfo("")
    DDLogInfo(" \033[2m This application is released under the MIT license. \033[0m\033[0m")
    DDLogInfo(self.copyrightNotice())
    
    // Displaying the help should not be interpreted as a success.
    // That's why we exit with a non-zero status code.
    return 99
  }
  
  public class func showVersion() -> Int32 {
    DDLogDebug("Showing version...")
    let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    DDLogInfo(version)
    return 98
  }
  
  private class func copyrightNotice() -> String {
    return " \033[2m Copyright (c) 2014-\(self.currentYear()) halo. See https://github.com/halo/macosvpn \033[0m\033[0m"
  }
  
  private class func currentYear() -> String {
    let formatter: NSDateFormatter = NSDateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter.stringFromDate(NSDate())
  }
  
}