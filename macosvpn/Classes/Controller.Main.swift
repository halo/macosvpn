public enum Controller {
  public enum Main {
    public static func call() -> Int32 {
      do {
        // Parse all CLI arguments
        try Arguments.load()

      } catch let error as ExitError {
        Log.error(error.localizedDescription)
        return error.code.rawValue

      } catch {
        Log.debug("Unexpected error: \(error.localizedDescription)")
        return ExitCode.unexpectedControllerRunError.rawValue
      }

      // Adding the --version flag should never perform anything
      // except for showing the version (without any blank rows).
      if Arguments.options.command == .version {
        Help.showVersion()
        return ExitCode.showingVersion.rawValue
      }

      // In every other case, we print out an empty row for readability.
      Log.info("")
      // And one empty row after.
      defer { Log.info(" ") }

      // Adding the --help flag should simply show the help.
      // This will be padded with blank lines above and under.
      if Arguments.options.command == .help {
        Help.showHelp()
        return ExitCode.showingHelp.rawValue
      }

      do {
        try Controller.Run.call()

      } catch let error as ExitError {
        Log.error(error.localizedDescription)
        return error.code.rawValue

      } catch {
        Log.debug("Unexpected error: \(error.localizedDescription)")
        return ExitCode.unexpectedControllerRunError.rawValue
      }

      // Mention that there were no errors so we can trace bugs more easily.
      Log.info("Finished without errors.")
      return ExitCode.success.rawValue
    }
  }
}
