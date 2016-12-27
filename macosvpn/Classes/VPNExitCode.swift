struct VPNExitCode {

  static let Success: Int32 = 0
  static let ShowingVersion: Int32 = 10
  static let ShowingHelp: Int32 = 11

  static let UnknownCommand: Int32 = 20
  static let MissingEndpoint: Int32 = 21
  static let MissingServices: Int32 = 22

  static let PrivilegesRequired: Int32 = 31
  static let LockingPreferencesFailed: Int32 = 32
  static let NoAuthorization: Int32 = 33

  static let UnsupportedInterfaceType: Int32 = 40
  static let InterfaceInitializationFailed: Int32 = 41
  static let NetworkServiceCreationFailed: Int32 = 42
  static let NetworkServiceNamingFailed: Int32 = 43
  static let PPPInterfaceConfigurationFailed: Int32 = 44
  static let IPSecInterfaceConfigurationFailed: Int32 = 45
  static let CiscoInterfaceConfigurationFailed: Int32 = 46
  static let CreatorDoesNotSupportInterfaceType: Int32 = 47
  static let DefaultConfigurationFailed: Int32 = 48
  static let CopyingCurrentNetworkSetFailed: Int32 = 49
  static let CopyingNetworkServicesFailed: Int32 = 50
  static let GettingServiceNameFailed: Int32 = 51
  static let GettingServiceIDFailed: Int32 = 52
  static let RefusingToOverwriteExistingService: Int32 = 53
  static let RemovingDuplicateServiceFailed: Int32 = 54
  static let CopyingServiceProtocolFailed: Int32 = 55
  static let SettingNetworkProtocolConfigFailed: Int32 = 56
  static let AddingNetworkServiceFailed: Int32 = 57
  static let CreatingPasswordKeychainItemFailed: Int32 = 58
  static let CreatingSharedSecretKeychainItemFailed: Int32 = 59
  static let CommingingPreferencesFailed: Int32 = 60
  static let ApplyingPreferencesFailed: Int32 = 61

}
