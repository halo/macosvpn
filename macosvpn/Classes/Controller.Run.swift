import Foundation

extension Controller {
  public enum Run {
    public static func call() throws {
      // To keep this application extensible we introduce different
      // commands right from the beginning. We start off with "create"
      if Arguments.options.command == .create {
        Log.debug("You wish to create one or more VPN service(s)")
        try Create.call()

      } else if Arguments.options.command == .delete {
        Log.debug("You wish to delete one or more VPN service(s)")
        try Delete.call()

      } else {
        throw ExitError(message: "Unknown command. Try --help for instructions.",
                        code: .unknownCommand)
      }
    }
  }
}
