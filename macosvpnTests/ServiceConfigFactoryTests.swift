import XCTest
@testable import macosvpn

class ServiceConfigFactoryTests: XCTestCase {

  func testMakeL2TP() {
    let arguments = [
      "--l2tp", "Atlantic",
      "--endpoint", "example.com",
      "--username", "Alice",
      "--password", "p4ssw0rd",
      "--sharedsecret", "s3same",
      "--groupname", "Dreamteam",
      "--disconnectswitch",
      "--disconnectlogout",
      "--split",
     ]

    let service = VPNServiceConfig.Factory.make(from: arguments)
    XCTAssertEqual(service.kind, .L2TP)
    XCTAssertEqual(service.name, "Atlantic")
    XCTAssertEqual(service.endpoint, "example.com")
    XCTAssertEqual(service.username, "Alice")
    XCTAssertEqual(service.password, "p4ssw0rd")
    XCTAssertEqual(service.sharedSecret, "s3same")
    XCTAssertEqual(service.localIdentifier, "Dreamteam")
    XCTAssertTrue(service.disconnectOnSwitch)
    XCTAssertTrue(service.disconnectOnLogout)
    XCTAssertTrue(service.enableSplitTunnel)
  }
  
  func testMakeCisco() {
    let arguments = [
      "--cisco", "Atlantic",
      "--endpoint", "example.com",
      "--username", "Alice",
      "--password", "p4ssw0rd",
      "--sharedsecret", "s3same",
      "--groupname", "Dreamteam",
     ]

    let service = VPNServiceConfig.Factory.make(from: arguments)
    XCTAssertEqual(service.kind, .Cisco)
    XCTAssertEqual(service.name, "Atlantic")
    XCTAssertEqual(service.endpoint, "example.com")
    XCTAssertEqual(service.username, "Alice")
    XCTAssertEqual(service.password, "p4ssw0rd")
    XCTAssertEqual(service.sharedSecret, "s3same")
    XCTAssertEqual(service.localIdentifier, "Dreamteam")
  }


}
