import XCTest
@testable import macosvpn

class VPNServiceConfigTests: XCTestCase {

  func testEnableSplitTunnel() {
    let config = VPNServiceConfig()
    XCTAssertFalse(config.enableSplitTunnel)
  }
  
  //func testL2TPPPPConfig() {
  //  let config = VPNServiceConfig()
  //  let dict = config.l2TPPPPConfig as Dictionary
  //  XCTAssertEqual(dict.first, "asd")
  //}
  

}
