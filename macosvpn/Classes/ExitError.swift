import Foundation
import SystemConfiguration

struct ExitError: LocalizedError {
  let message: String
  let code: ExitReason
  let securityStatus: OSStatus?
  let systemStatus: OSStatus?

  public init(message: String, code: ExitReason) {
    self.message = message
    self.code = code
    self.securityStatus = nil
    self.systemStatus = nil
  }

  public init(message: String, code: ExitReason, securityStatus: OSStatus) {
    self.message = message
    self.code = code
    self.securityStatus = securityStatus
    self.systemStatus = nil
  }

  public init(message: String, code: ExitReason, systemStatus: OSStatus) {
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
      return "(Security Framwork Error Code \(status))"
    }

    return "\(message) (Security Framwork Error Code \(status))"
  }

  private var systemConfigurationErrorMessage: String? {
    guard let status = systemStatus else { return nil }

    let message = String(cString: SCErrorString(SCError()))

    return "\(message) (System Configuration Error Code \(status))"
  }
}
