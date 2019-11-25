import XCTest
@testable import macosvpn

class ServiceConfigSplitterTests: XCTestCase {

  func testEnableSplitTunnel() {
    let arguments: [String] = []
    let services = VPNServiceConfig.Splitter.parse(arguments)
    XCTAssertEqual(services, [])
  }

  func testSingleServices() {
    let arguments = [
      "--l2tp", "Atlantic",
      "--endpoint", "example.com",
    ]
    let services = VPNServiceConfig.Splitter.parse(arguments)
    let service = services.first!

    XCTAssertEqual(service.kind, .L2TP)
  }

  func testMultipleServices() {
    let arguments = [
      "--l2tp", "Atlantic",
      "--endpoint", "atlantic.example.com",
      "--cisco", "London",
      "--endpoint", "london.example.com",
    ]
    let services = VPNServiceConfig.Splitter.parse(arguments)
    let service1 = services.first!
    let service2 = services.last!

    XCTAssertEqual(service1.kind, .L2TP)
    XCTAssertEqual(service1.name, "Atlantic")
    XCTAssertEqual(service1.endpoint, "atlantic.example.com")

    XCTAssertEqual(service2.kind, .Cisco)
    XCTAssertEqual(service2.name, "London")
    XCTAssertEqual(service2.endpoint, "london.example.com")
  }
}
