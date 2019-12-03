import XCTest
@testable import macosvpn

class ServiceConfigParserTests: XCTestCase {
  
  func testMakeMinimalL2TP() {
    let arguments = [
      "--l2tp", "Atlantic",
      "--endpoint", "example.com",
    ]
    
    let service = ServiceConfig.Parser.parse(arguments)
    XCTAssertEqual(service.kind, .L2TPOverIPSec)
    XCTAssertEqual(service.name, "Atlantic")
    XCTAssertEqual(service.endpoint, "example.com")
    XCTAssertNil(service.username)
    XCTAssertNil(service.password)
    XCTAssertNil(service.sharedSecret)
    XCTAssertNil(service.localIdentifier)
    XCTAssertFalse(service.disconnectOnSwitch)
    XCTAssertFalse(service.disconnectOnLogout)
    XCTAssertFalse(service.enableSplitTunnel)
  }
  
  func testMakeFullL2TP() {
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
    
    let service = ServiceConfig.Parser.parse(arguments)
    XCTAssertEqual(service.kind, .L2TPOverIPSec)
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
  
  func testMakeMinimalCisco() {
    let arguments = [
      "--cisco", "Atlantic",
      "--endpoint", "example.com",
    ]
    
    let service = ServiceConfig.Parser.parse(arguments)
    XCTAssertEqual(service.kind, .CiscoIPSec)
    XCTAssertEqual(service.name, "Atlantic")
    XCTAssertEqual(service.endpoint, "example.com")
    XCTAssertNil(service.username)
    XCTAssertNil(service.password)
    XCTAssertNil(service.sharedSecret)
    XCTAssertNil(service.localIdentifier)
  }

  func testMakeFullCisco() {
    let arguments = [
      "--cisco", "Atlantic",
      "--endpoint", "example.com",
      "--username", "Alice",
      "--password", "p4ssw0rd",
      "--sharedsecret", "s3same",
      "--groupname", "Dreamteam",
    ]
    
    let service = ServiceConfig.Parser.parse(arguments)
    XCTAssertEqual(service.kind, .CiscoIPSec)
    XCTAssertEqual(service.name, "Atlantic")
    XCTAssertEqual(service.endpoint, "example.com")
    XCTAssertEqual(service.username, "Alice")
    XCTAssertEqual(service.password, "p4ssw0rd")
    XCTAssertEqual(service.sharedSecret, "s3same")
    XCTAssertEqual(service.localIdentifier, "Dreamteam")
  }

}
