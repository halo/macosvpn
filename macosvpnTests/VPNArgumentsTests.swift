import XCTest
@testable import macosvpn

class VPNArgumentsTests: XCTestCase {

  func testparse() {
      let config = VPNArguments()
      XCTAssertEqual(config.parse(), "hi")
    }

}
