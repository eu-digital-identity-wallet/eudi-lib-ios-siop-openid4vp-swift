import XCTest
import JSONSchema
import Sextant

@testable import openid4vp_ios

final class JWTTests: XCTestCase {
  
  func testJWTIsValidGivenValidString() throws {
    let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"

    let jsonWebToken = JSONWebToken(
      jsonWebToken: token
    )
    
    let name = jsonWebToken!.payload["name"] as? String
    XCTAssert(name! == "John Doe")
  }
}
