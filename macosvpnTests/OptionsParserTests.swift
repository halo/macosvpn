import XCTest
@testable import macosvpn

class OptionsParserTests: XCTestCase {
  
  func testDefault() {
    let options = Options.Parser.parse([])
    XCTAssertEqual(options.command, .help)
  }

  func testHelpRequestedShort() {
    let options = Options.Parser.parse(["create", "-h"])
    XCTAssertEqual(options.command, .help)
  }

  func testHelpRequestedLong() {
    let options = Options.Parser.parse(["create", "--help"])
    XCTAssertEqual(options.command, .help)
    XCTAssertEqual(options.unprocessedArguments, [])
  }

  func testHelpAndVersionRequested() {
    let options = Options.Parser.parse(["--help", "--version"])
    XCTAssertEqual(options.command, .help)
    XCTAssertEqual(options.unprocessedArguments, [])
  }

  func testExtraneousArguments() {
    let options = Options.Parser.parse(["--help", "--whatisthis"])
    XCTAssertEqual(options.unprocessedArguments, ["--whatisthis"])
  }

  func testCommand() {
    let options = Options.Parser.parse(["create"])
    XCTAssertEqual(options.command, .create)
  }
//
  //func testMissingCommand() {
  //  let arguments: [String] = []
  //  Options.instance.arguments = arguments
  //  XCTAssertEqual(Options.cmd, Command.help)
  //}
//
  ////func testL2TP() {
  ////  let arguments = ["--l2tp", "Atlantic"]
  ////  Options.instance.arguments = arguments
  ////  XCTAssertEqual(Options.l2tps, ["Atlantic"])
  ////}
////
  ////func testMultipleL2TP() {
  ////  let arguments = ["--l2tp", "Atlantic", "--l2tp", "Pacific"]
  ////  Options.instance.arguments = arguments
  ////  XCTAssertEqual(Options.l2tps, ["Atlantic", "Pacific"])
  ////}
////
  ////func testMultipleUsernames() {
  ////  let arguments = ["--username", "Alice",
  ////                   "--username", "Bob"]
  ////  Options.instance.arguments = arguments
  ////  XCTAssertEqual(Options.usernames, ["Alice", "Bob"])
  ////}
  ////
  ////func testMultipleL2TPWithUsernames() {
  ////  let arguments = ["--l2tp", "Atlantic", "--username", "Alice",
  ////                  "--l2tp", "Pacific", "--username", "Bob"]
  ////  Options.instance.arguments = arguments
  ////  XCTAssertEqual(Options.l2tps, ["Atlantic", "Pacific"])
  ////  XCTAssertEqual(Options.usernames, ["Alice", "Bob"])
  ////}
//
  //func testServiceConfigArgumentsWithMissingCommand() {
  //  let arguments = ["--l2tp", "Atlantic", "--username", "Alice",
  //                  "--cisco", "Pacific", "--username", "Bob"]
  //  Options.instance.arguments = arguments
  //  XCTAssertEqual(Options.cmd, .help)
  //  XCTAssertEqual(Options.instance.serviceConfigArguments, [])
  //}
//
  //func testServiceConfigArguments() {
  //  let arguments = ["create", "--l2tp", "Atlantic", "--username", "Alice",
  //                  "--cisco", "Pacific", "--username", "Bob"]
  //  Options.instance.arguments = arguments
  //  XCTAssertEqual(Options.cmd, .create)
  //  XCTAssertEqual(Options.instance.serviceConfigArguments, [
  //    ["--l2tp", "Atlantic", "--username", "Alice"],
  //    ["--cisco", "Pacific", "--username", "Bob"]
  //  ])
  //}

}
