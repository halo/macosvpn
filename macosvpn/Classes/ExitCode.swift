/*
 * Copyright (C) 2014-2019 halo https://github.com/halo/macosvpn
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

enum ExitCode: Int32 {
  case success = 0

  case todo = 1

  // Controller.Main
  case showingVersion = 2
  case showingHelp = 3
  case unexpectedControllerRunError = 4
  // Controller.Run
  case unknownCommand = 10
  // Controller.Create
  case privilegesRequired = 20
  case couldNotLockSystemPreferences = 21
  case mustSpecifySomeServiceToCreate = 22
  // Controller.Delete
  case unclearWhichServicesToDelete = 30

  // Keychain
  case couldNotRetrieveSystemKeychain = 40
  case couldNotUnwrapSystemKeychain = 41
  case couldNotUnlockSystemKeychain = 42

  // Authroization
  case couldNotCreateAuthorization = 50
  case couldNotUnwrapAuthorization = 52
  case couldNotCreatePreferences = 53

  // NetworkInterface.Instantiate
  case couldNotInitializeL2TPInterface = 60
  case couldNotInitializePPPInterface = 61
  case couldNotInitializeIPSecInterface = 62

  // NetworkSet.RemoveServices
  case removingDuplicateServiceFailed = 70
  case removingServiceFailed = 71
  case noServicesRemoved = 72
  case refusingToOverwriteExistingService = 73

  // Services
  case couldNotFetchCurrentNetworkSet = 80
  case couldNotRetrieveServicesFromNetworkSet = 81

  // Options
  case invalidCommand = 82

  // ServiceConfig
  case invalidServiceKindCalled = 90
  // ServiceConfig.Parser
  case invalidServiceConfigArgumentsDetected = 100
  case invalidServiceKindDetected = 101
  case missingEndpoint = 102
  // ServiceConfig.Remover/.Creator
  case committingPreferencesFailed = 110
  case applyingPreferencesFailed = 111
  // ServiceConfig.Creator
  case networkServiceCreationFailed = 120
  case defaultConfigurationFailed = 121
  case networkServiceNamingFailed = 122


}
