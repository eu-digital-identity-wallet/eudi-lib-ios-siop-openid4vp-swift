import XCTest
import JSONSchema
import Sextant

@testable import openid4vp_ios

final class ExtensionsTests: XCTestCase {
  
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
