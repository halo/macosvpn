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

import Foundation
import SystemConfiguration

struct ExitError: LocalizedError {
  let message: String
  let code: ExitCode
  let securityStatus: OSStatus?
  let systemStatus: Bool

  public init(message: String, code: ExitCode) {
    self.message = message
    self.code = code
    self.securityStatus = nil
    self.systemStatus = false
  }

  public init(message: String, code: ExitCode, securityStatus: OSStatus) {
    self.message = message
    self.code = code
    self.securityStatus = securityStatus
    self.systemStatus = false
  }

  public init(message: String, code: ExitCode, systemStatus: Bool) {
    self.message = message
    self.code = code
    self.securityStatus = nil
    self.systemStatus = systemStatus
  }

  public var errorDescription: String? {
    [
      message,
      securityFrameworkErrorMessage,
      systemConfigurationErrorMessage,
      ].compactMap { $0 }.joined(separator: ". ")
  }

  private var securityFrameworkErrorMessage: String? {
    guard let status = securityStatus else { return nil }

    guard let message = SecCopyErrorMessageString(status, nil) else {
      return "(Security Framwork Error \(status))."
    }

    return "\(message) (Security Framwork Error Code \(status))."
  }

  private var systemConfigurationErrorMessage: String? {
    guard systemStatus else { return nil }
    guard SCError() > 0 else { return nil }

    let message = String(cString: SCErrorString(SCError()))

    return "\(message) (System Configuration Error \(SCError()))."
  }
}
