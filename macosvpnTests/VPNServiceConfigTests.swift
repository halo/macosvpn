import XCTest
@testable import macosvpn

class VPNServiceConfigTests: XCTestCase {

  //func testEnableSplitTunnel() {
  //  let config = VPNServiceConfig(kind: .L2TPOverIPSec,
  //                                name: "Atlantic",
  //                                endpoint: "example.com")
  //  XCTAssertFalse(config.enableSplitTunnel)
  //}
  
  func testL2TPPPPConfig() {
    let config = VPNServiceConfig(kind: .L2TPOverIPSec,
                                  name: "Atlantic",
                                  endpoint: "example.com")
    //let dict = config.l2TPPPPConfig as Dictionary<CFString>
    //XCTAssertEqual(dict, ["a": "test"])
  }
  

}
