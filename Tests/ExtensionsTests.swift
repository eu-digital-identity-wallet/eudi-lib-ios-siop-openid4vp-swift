import XCTest
import JSONSchema
import Sextant

@testable import SiopOpenID4VP

final class ExtensionsTests: XCTestCase {
  
  func testArraySubscriptGivenInboundsIndex() {
    let array = [0, 1, 2, 3, 4, 5, 6]
    XCTAssertTrue(array[safe: 1] == 1)
  }
  
  func testArraySubscriptGivenOutOfboundsIndex() {
    let array = [0, 1, 2, 3, 4, 5, 6]
    XCTAssertNil(array[safe: 10])
  }
  
  func testJsonPathSyntaxIsValid() throws {
    let path1 = "$.name"
    let path2 = "$.friends[*].name"
    let path3 = "$.credentialSubject.account[*].id"
    let path4 = "$.vc.credentialSubject.account[*].id"
    let path5 = "$.account[*].id"

    XCTAssert(path1.isValidJSONPath)
    XCTAssert(path2.isValidJSONPath)
    XCTAssert(path3.isValidJSONPath)
    XCTAssert(path4.isValidJSONPath)
    XCTAssert(path5.isValidJSONPath)
  }
  
  func testJsonPathSyntaxIsInvalid() throws {
    let path1 = "$..book[?(@.price<10)].title"
    XCTAssertFalse(path1.isValidJSONPath)
  }
}
