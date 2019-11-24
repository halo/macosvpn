import XCTest
@testable import macosvpn

class RuntimeFactoryTests: XCTestCase {
  
  func testDefault() {
    let runtime = Runtime.Factory.make([])
    XCTAssertEqual(runtime.command, .help)
  }

  func testhelpRequestedShort() {
    let runtime = Runtime.Factory.make(["create", "-h"])
    XCTAssertEqual(runtime.command, .help)
  }

  func testhelpRequestedLong() {
    let runtime = Runtime.Factory.make(["create", "--help"])
    XCTAssertEqual(runtime.command, .help)
  }

  func testCommand() {
    let runtime = Runtime.Factory.make(["create"])
    XCTAssertEqual(runtime.command, .create)
  }
//
  //func testMissingCommand() {
  //  let arguments: [String] = []
  //  Runtime.instance.arguments = arguments
  //  XCTAssertEqual(Runtime.cmd, Command.help)
  //}
//
  ////func testL2TP() {
  ////  let arguments = ["--l2tp", "Atlantic"]
  ////  Runtime.instance.arguments = arguments
  ////  XCTAssertEqual(Runtime.l2tps, ["Atlantic"])
  ////}
////
  ////func testMultipleL2TP() {
  ////  let arguments = ["--l2tp", "Atlantic", "--l2tp", "Pacific"]
  ////  Runtime.instance.arguments = arguments
  ////  XCTAssertEqual(Runtime.l2tps, ["Atlantic", "Pacific"])
  ////}
////
  ////func testMultipleUsernames() {
  ////  let arguments = ["--username", "Alice",
  ////                   "--username", "Bob"]
  ////  Runtime.instance.arguments = arguments
  ////  XCTAssertEqual(Runtime.usernames, ["Alice", "Bob"])
  ////}
  ////
  ////func testMultipleL2TPWithUsernames() {
  ////  let arguments = ["--l2tp", "Atlantic", "--username", "Alice",
  ////                  "--l2tp", "Pacific", "--username", "Bob"]
  ////  Runtime.instance.arguments = arguments
  ////  XCTAssertEqual(Runtime.l2tps, ["Atlantic", "Pacific"])
  ////  XCTAssertEqual(Runtime.usernames, ["Alice", "Bob"])
  ////}
//
  //func testServiceConfigArgumentsWithMissingCommand() {
  //  let arguments = ["--l2tp", "Atlantic", "--username", "Alice",
  //                  "--cisco", "Pacific", "--username", "Bob"]
  //  Runtime.instance.arguments = arguments
  //  XCTAssertEqual(Runtime.cmd, .help)
  //  XCTAssertEqual(Runtime.instance.serviceConfigArguments, [])
  //}
//
  //func testServiceConfigArguments() {
  //  let arguments = ["create", "--l2tp", "Atlantic", "--username", "Alice",
  //                  "--cisco", "Pacific", "--username", "Bob"]
  //  Runtime.instance.arguments = arguments
  //  XCTAssertEqual(Runtime.cmd, .create)
  //  XCTAssertEqual(Runtime.instance.serviceConfigArguments, [
  //    ["--l2tp", "Atlantic", "--username", "Alice"],
  //    ["--cisco", "Pacific", "--username", "Bob"]
  //  ])
  //}

}
