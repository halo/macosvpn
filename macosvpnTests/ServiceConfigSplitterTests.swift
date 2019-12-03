import XCTest
@testable import macosvpn

class ServiceConfigSplitterTests: XCTestCase {

  //func testEnableSplitTunnel() {
  //  let arguments: [String] = []
  //  let services = ServiceConfig.Splitter.parse(arguments)
  //  XCTAssertEqual(services, [])
  //}

  func testSingleServices() {
    let arguments = [
      "--l2tp", "Atlantic",
      "--endpoint", "example.com",
    ]
    let services = ServiceConfig.Splitter.parse(arguments)
    let service = services.first!

    XCTAssertEqual(service.kind, .L2TPOverIPSec)
  }

  func testMultipleServices() {
    let arguments = [
      "--l2tp", "Atlantic",
      "--endpoint", "atlantic.example.com",
      "--cisco", "London",
      "--endpoint", "london.example.com",
    ]
    let services = ServiceConfig.Splitter.parse(arguments)
    let service1 = services.first!
    let service2 = services.last!

    XCTAssertEqual(service1.kind, .L2TPOverIPSec)
    XCTAssertEqual(service1.name, "Atlantic")
    XCTAssertEqual(service1.endpoint, "atlantic.example.com")

    XCTAssertEqual(service2.kind, .CiscoIPSec)
    XCTAssertEqual(service2.name, "London")
    XCTAssertEqual(service2.endpoint, "london.example.com")
  }
}
