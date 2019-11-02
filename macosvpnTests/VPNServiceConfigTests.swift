import XCTest
@testable import macosvpn

class VPNServiceConfigTests: XCTestCase {

  func testEnableSplitTunnel() {
     let config = VPNServiceConfig()
     XCTAssertFalse(config.enableSplitTunnel)
   }

}
