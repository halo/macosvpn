import XCTest
@testable import macosvpn

class VPNArgumentsTests: XCTestCase {
  func testDefault() {
    VPNArguments.instance.arguments = []
    XCTAssertFalse(VPNArguments.helpRequested)
  }

  func testhelpRequestedShort() {
    let arguments = ["-h"]
    VPNArguments.instance.arguments = arguments
    XCTAssertTrue(VPNArguments.helpRequested)
  }

  func testhelpRequestedLong() {
    let arguments = ["--help"]
    VPNArguments.instance.arguments = arguments
    XCTAssertTrue(VPNArguments.helpRequested)
  }

  //func testL2TP() {
  //  let arguments = ["--l2tp", "Atlantic"]
  //  VPNArguments.instance.arguments = arguments
  //  XCTAssertEqual(VPNArguments.l2tps, ["Atlantic"])
  //}
//
  //func testMultipleL2TP() {
  //  let arguments = ["--l2tp", "Atlantic", "--l2tp", "Pacific"]
  //  VPNArguments.instance.arguments = arguments
  //  XCTAssertEqual(VPNArguments.l2tps, ["Atlantic", "Pacific"])
  //}
//
  //func testMultipleUsernames() {
  //  let arguments = ["--username", "Alice",
  //                   "--username", "Bob"]
  //  VPNArguments.instance.arguments = arguments
  //  XCTAssertEqual(VPNArguments.usernames, ["Alice", "Bob"])
  //}
  //
  //func testMultipleL2TPWithUsernames() {
  //  let arguments = ["--l2tp", "Atlantic", "--username", "Alice",
  //                  "--l2tp", "Pacific", "--username", "Bob"]
  //  VPNArguments.instance.arguments = arguments
  //  XCTAssertEqual(VPNArguments.l2tps, ["Atlantic", "Pacific"])
  //  XCTAssertEqual(VPNArguments.usernames, ["Alice", "Bob"])
  //}

  func testL2TPAndCisco() {
    let arguments = ["asd", "--l2tp", "Atlantic", "--username", "Alice",
                    "--cisco", "Pacific", "--username", "Bob"]
    VPNArguments.instance.arguments = arguments
    XCTAssertEqual(VPNArguments.instance.serviceConfigArguments, [["Atlantic"]])
    //XCTAssertEqual(VPNArguments.ciscos, ["Pacific"])
    //XCTAssertEqual(VPNArguments.usernames, ["Alice", "Bob"])
  }

}
