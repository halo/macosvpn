import XCTest
@testable import macosvpn

class ServiceConfigTests: XCTestCase {

  func testDescriptionL2TPMinimal() {
    let config = ServiceConfig(kind: .L2TPOverIPSec,
                               name: "Atlantic",
                               endpoint: "example.com")

    XCTAssertEqual(config.description,
                   "<[ServiceConfig L2TPOverIPSec] " +
                    "name=Atlantic " +
                    "endpoint=example.com " +
                    "enableSplitTunnel=false " +
                    "disconnectOnSwitch=false " +
      "disconnectOnLogout=false>")
  }

  func testDescriptionL2TPFull() {
    let config = ServiceConfig(kind: .L2TPOverIPSec,
                               name: "Atlantic",
                               endpoint: "example.com")
    config.username = "Alice"
    config.password = "p4ssw0rd"
    config.sharedSecret = "s3cret"
    config.localIdentifier = "Dreamteam"
    config.enableSplitTunnel = true
    config.disconnectOnSwitch = true
    config.disconnectOnLogout = true

    XCTAssertEqual(config.description,
                   "<[ServiceConfig L2TPOverIPSec] " +
                    "name=Atlantic " +
                    "endpoint=example.com " +
                    "username=Alice " +
                    "password=p4ssw0rd " +
                    "sharedSecret=s3cret " +
                    "localIdentifier=Dreamteam " +
                    "enableSplitTunnel=true " +
                    "disconnectOnSwitch=true " +
      "disconnectOnLogout=true>")
  }

  func testDescriptionCiscoMinimal() {
    let config = ServiceConfig(kind: .CiscoIPSec,
                               name: "Atlantic",
                               endpoint: "example.com")

    XCTAssertEqual(config.description,
                   "<[ServiceConfig CiscoIPSec] " +
                    "name=Atlantic " +
      "endpoint=example.com>")
  }

  func testDescriptionCiscoFull() {
    let config = ServiceConfig(kind: .CiscoIPSec,
                               name: "Atlantic",
                               endpoint: "example.com")
    config.username = "Alice"
    config.password = "p4ssw0rd"
    config.sharedSecret = "s3cret"
    config.localIdentifier = "Dreamteam"
    config.enableSplitTunnel = true
    config.disconnectOnSwitch = true
    config.disconnectOnLogout = true

    XCTAssertEqual(config.description,
                   "<[ServiceConfig CiscoIPSec] " +
                    "name=Atlantic " +
                    "endpoint=example.com " +
                    "username=Alice " +
                    "password=p4ssw0rd " +
                    "sharedSecret=s3cret " +
      "localIdentifier=Dreamteam>")
  }

  func testL2TPPPPConfig() {
    let config = ServiceConfig(kind: .L2TPOverIPSec,
                               name: "Atlantic",
                               endpoint: "example.com")

    XCTAssertEqual(config.l2TPPPPConfig,
                   ["AuthName": nil,
                    "AuthPassword": nil,
                    "AuthPasswordEncryption": "Keychain",
                    "CommRemoteAddress": "example.com",
                    "DisconnectOnFastUserSwitch": "0",
                    "DisconnectOnLogout": "0",
                    ] as CFDictionary)
  }

  func testL2TPPPPConfigDisconnect() {
    let config = ServiceConfig(kind: .L2TPOverIPSec,
                               name: "Atlantic",
                               endpoint: "example.com")
    config.disconnectOnLogout = true
    config.disconnectOnSwitch = true

    XCTAssertEqual(config.l2TPPPPConfig,
                   ["AuthName": nil,
                    "AuthPassword": nil,
                    "AuthPasswordEncryption": "Keychain",
                    "CommRemoteAddress": "example.com",
                    "DisconnectOnFastUserSwitch": "1",
                    "DisconnectOnLogout": "1",
                    ] as CFDictionary)
  }

  func testL2TPIPSecConfig() {
    let config = ServiceConfig(kind: .L2TPOverIPSec,
                               name: "Atlantic",
                               endpoint: "example.com")
    config.serviceID = "my-service-id"

    XCTAssertEqual(config.l2TPIPSecConfig,
                   ["AuthenticationMethod": "SharedSecret",
                    "SharedSecret": "my-service-id.SS",
                    "SharedSecretEncryption": "Keychain"
                    ] as CFDictionary)
  }

  func testL2TPIPSecConfigWithGroupName() {
    let config = ServiceConfig(kind: .L2TPOverIPSec,
                               name: "Atlantic",
                               endpoint: "example.com")
    config.serviceID = "my-service-id"
    config.localIdentifier = "Dreamteam"

    XCTAssertEqual(config.l2TPIPSecConfig,
                   ["AuthenticationMethod": "SharedSecret",
                    "LocalIdentifier": "Dreamteam",
                    "LocalIdentifierType": "KeyID",
                    "SharedSecret": "my-service-id.SS",
                    "SharedSecretEncryption": "Keychain"
                    ] as CFDictionary)
  }

  func testL2TPIPv4Config() {
    let config = ServiceConfig(kind: .L2TPOverIPSec,
                               name: "Atlantic",
                               endpoint: "example.com")
    config.enableSplitTunnel = false

    XCTAssertEqual(config.l2TPIPv4Config,
                   ["ConfigMethod": "PPP",
                    "OverridePrimary": "1",
                    ] as CFDictionary)
  }

  func testL2TPIPv4ConfigSplitTunnel() {
    let config = ServiceConfig(kind: .L2TPOverIPSec,
                               name: "Atlantic",
                               endpoint: "example.com")
    config.enableSplitTunnel = true

    XCTAssertEqual(config.l2TPIPv4Config,
                   ["ConfigMethod": "PPP",
                    ] as CFDictionary)
  }

}
