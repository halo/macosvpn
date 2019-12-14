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
