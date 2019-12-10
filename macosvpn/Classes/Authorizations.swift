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

import SystemConfiguration

enum Authorization {
  static func preferences() throws -> SCPreferences {
    var auth: AuthorizationRef?
    var status: OSStatus

    Log.debug("Obtaining Authorization...")
    status = AuthorizationCreate(nil, nil, self.flags, &auth)

    if status != errAuthorizationSuccess {
      throw ExitError(message: "Creating Authorization Failed",
                      code: .couldNotCreateAuthorization,
                      securityStatus: status)
    }

    guard let authorization = auth else {
      throw ExitError(message: "Created Authorization could not be unwrapped",
                      code: .couldNotUnwrapAuthorization)
    }

    Log.debug("Authorization successfully obtained")

    let app = "macosvpn" as CFString
    
    guard let preferences = SCPreferencesCreateWithAuthorization(nil, app, nil, authorization) else {
      throw ExitError(message: "Could not Authorizes Preferences",
                      code: .couldNotCreatePreferences,
                      securityStatus: status)
    }

    return preferences
  }

  private static var flags: AuthorizationFlags {
    return [.extendRights, .interactionAllowed, .preAuthorize]
  }
}
