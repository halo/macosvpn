// TODO: Rename to `ExitCode`
enum ExitCode: Int32 {

  case todo = 1

  // Controller.Main
  case success = 0
  case showingVersion = 100
  case showingHelp = 110
  case unexpectedControllerRunError = 120
  // Controller.Run
  case unknownCommand = 130
  // Controller.Create
  case privilegesRequired = 140
  case couldNotLockSystemPreferences = 150
  case mustSpecifySomeServiceToCreate = 160
  // Controller.Delete
  case unclearWhichServicesToDelete = 170

  // Keychain
  case couldNotRetrieveSystemKeychain = 300
  case couldNotUnwrapSystemKeychain = 310
  case couldNotUnlockSystemKeychain = 320

  // Authroization
  case couldNotCreateAuthorization = 400
  case couldNotUnwrapAuthorization = 410
  case couldNotCreatePreferences = 420

  // NetworkInterface.Instantiate
  case couldNotInitializeL2TPInterface = 500
  case couldNotInitializePPPInterface = 510
  case couldNotInitializeIPSecInterface = 520

  // Services
  case couldNotFetchCurrentNetworkSet = 600
  case couldNotRetrieveServicesFromNetworkSet = 610

  // Options
  case argumentParserFailedUnexpectedly = 700

  // ServiceConfig
  case invalidServiceKindCalled = 810
  // ServiceConfig.Parser
  case invalidServiceConfigArgumentsDetected = 800
  case invalidServiceKindDetected = 820
  case missingEndpoint = 830
}



// Delete this!
//enum ExitCode {


 //static let MissingEndpoint: Int32 = 21
 //static let MissingServices: Int32 = 22
 //static let MissingNames: Int32 = 23
 //static let ServiceNameExtractionFailed: Int32 = 24
 //static let UnknownService: Int32 = 25
 //static let InvalidArguments: Int32 = 26
 //static let UnknownArguments: Int32 = 27



 //static let PrivilegesRequired: Int32 = 31
 //static let LockingPreferencesFailed: Int32 = 32
 //static let NoAuthorization: Int32 = 33
 //static let AuthorizationCreationFailed: Int32 = 34

 //static let UnsupportedInterfaceType: Int32 = 40
 //static let InterfaceInitializationFailed: Int32 = 41
 //static let NetworkServiceCreationFailed: Int32 = 42
 //static let NetworkServiceNamingFailed: Int32 = 43
 //static let PPPInterfaceConfigurationFailed: Int32 = 44
 //static let IPSecInterfaceConfigurationFailed: Int32 = 45
 //static let CiscoInterfaceConfigurationFailed: Int32 = 46
 //static let CreatorDoesNotSupportInterfaceType: Int32 = 47
 //static let DefaultConfigurationFailed: Int32 = 48
 //static let CopyingCurrentNetworkSetFailed: Int32 = 49
 //static let CopyingNetworkServicesFailed: Int32 = 50
 //static let GettingServiceNameFailed: Int32 = 51
 //static let GettingServiceIDFailed: Int32 = 52
 //static let RefusingToOverwriteExistingService: Int32 = 53
 //static let RemovingDuplicateServiceFailed: Int32 = 54
 //static let CopyingServiceProtocolFailed: Int32 = 55
 //static let SettingNetworkProtocolConfigFailed: Int32 = 56
 //static let AddingNetworkServiceFailed: Int32 = 57
 //static let CreatingPasswordKeychainItemFailed: Int32 = 58
 //static let CreatingSharedSecretKeychainItemFailed: Int32 = 59
 //static let CommingingPreferencesFailed: Int32 = 60
 //static let ApplyingPreferencesFailed: Int32 = 61
 //static let RemovingServiceFailed: Int32 = 62
 //static let NoServicesRemoved: Int32 = 63

 //// ServiceConfig
 //static let InvalidServiceConfigCall: Int32 = 80

//}
