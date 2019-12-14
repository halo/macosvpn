import XCTest
@testable import macosvpn

class OptionsParserTests: XCTestCase {
  
  func testDefault() {
    let options = try! Options.Parser.parse([])
    XCTAssertEqual(options.command, .help)
  }

  func testHelpRequestedShort() {
    let options = try! Options.Parser.parse(["create", "-h"])
    XCTAssertEqual(options.command, .help)
  }

  func testHelpRequestedLong() {
    let options = try! Options.Parser.parse(["create", "--help"])
    XCTAssertEqual(options.command, .help)
    XCTAssertEqual(options.unprocessedArguments, [])
  }

  func testHelpAndVersionRequested() {
    let options = try! Options.Parser.parse(["--help", "--version"])
    XCTAssertEqual(options.command, .help)
    XCTAssertEqual(options.unprocessedArguments, [])
  }

  func testExtraneousArguments() {
    let options = try! Options.Parser.parse(["--help", "--whatisthis"])
    XCTAssertEqual(options.unprocessedArguments, ["--whatisthis"])
  }

  func testCommandCreate() {
    let options = try! Options.Parser.parse(["create"])
    XCTAssertEqual(options.command, .create)
  }

  func testCommandDelete() {
    let options = try! Options.Parser.parse(["delete"])
    XCTAssertEqual(options.command, .delete)
  }

  func testCommandDeleteWithNames() {
    let options = try! Options.Parser.parse(
      ["delete", "--name", "One", "--name", "Two"]
    )
    XCTAssertEqual(options.names, ["One", "Two"])
  }
}
