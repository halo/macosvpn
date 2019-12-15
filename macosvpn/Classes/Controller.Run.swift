import Foundation

extension Controller {
  public enum Run {
    public static func call() throws {
      // To keep this application extensible we introduce different
      // commands right from the beginning. We start off with "create"
      switch Arguments.options.command {
      case .create:
        Log.debug("You wish to create one or more VPN service(s)")
        try Create.call()
        break

      case .delete:
        Log.debug("You wish to delete one or more VPN service(s)")
        try Delete.call()
        break

      default:
        throw ExitError(message: "Unknown command. Try --help for instructions.",
                        code: .unknownCommand)
      }
    }
  }
}
