import XCTest
@testable import macosvpn

class CollectionSplitTests: XCTestCase {

  func testSplit() {
    let arguments = [
      "one", "two",
      "three", "four",
    ]
    let delimiters = Set(arrayLiteral: "two")
    let slices =  arguments.split(before: delimiters.contains)

    XCTAssertEqual(slices, [["one"], ["two", "three", "four"]])
  }

  func testSplitTwo() {
    let arguments = [
      "one", "two",
      "one", "two",
    ]
    let delimiters = Set(arrayLiteral: "one")
    let slices =  arguments.split(before: delimiters.contains)

    XCTAssertEqual(slices, [["one", "two"], ["one", "two"]])
  }

  func testSplitThree() {
    let arguments = [
      "one", "two",
      "one", "two",
      "one", "two",
    ]
    let delimiters = Set(arrayLiteral: "one")
    let slices =  arguments.split(before: delimiters.contains)

    XCTAssertEqual(slices, [["one", "two"], ["one", "two"], ["one", "two"]])
  }

  func testSplitRepeatOptions() {
    let arguments = [
         "--cisco", "Atlantic",
         "--endpoint", "a.example.com",
         "-c", "London",
         "--endpoint", "l.example.com",
       ]
    let delimiters = Set(arrayLiteral: "-c", "--cisco")
    let slices =  arguments.split(before: delimiters.contains)

    XCTAssertEqual(slices, [
      ["--cisco", "Atlantic", "--endpoint", "a.example.com"],
      ["-c", "London", "--endpoint", "l.example.com"],
    ])
  }
}
