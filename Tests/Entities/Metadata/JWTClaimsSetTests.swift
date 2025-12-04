/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import XCTest
import SwiftyJSON
@testable import OpenID4VP

class JWTClaimsSetTests: XCTestCase {

  func testParseWhenValidJSON() throws {

    let timestamp = Int64(Date().timeIntervalSince1970)
    let json: [String: Any] = [
      "iss": "issuer",
      "sub": "subject",
      "aud": ["aud1", "aud2"],
      "exp": timestamp,
      "nbf": timestamp,
      "iat": timestamp,
      "jti": "jwt-id",
      "custom": "custom-claim"
    ]
    let claimsSet = try JWTClaimsSet.parse(json)

    XCTAssertEqual(claimsSet.issuer, "issuer")
    XCTAssertEqual(claimsSet.subject, "subject")
    XCTAssertEqual(claimsSet.audience, ["aud1", "aud2"])
    XCTAssertEqual(claimsSet.jwtID, "jwt-id")
    XCTAssertEqual(claimsSet.claims["custom"] as? String, "custom-claim")

    XCTAssertNotNil(claimsSet.expirationTime)
    XCTAssertNotNil(claimsSet.notBeforeTime)
    XCTAssertNotNil(claimsSet.issueTime)
  }

  func testParseClaimsAudienceWhenSingleString() throws {

    let json: [String: Any] = [
      "aud": "aud1"
    ]
    let claimsSet = try JWTClaimsSet.parse(json)
    let audClaim = claimsSet.claims["aud"]

    XCTAssertEqual(audClaim as? String, "aud1")
    XCTAssertEqual(claimsSet.audience, [])
  }

  func testParseWhenMissingOptionalClaims() throws {

    let json: [String: Any] = [:]
    let claimsSet = try JWTClaimsSet.parse(json)

    XCTAssertNil(claimsSet.issuer)
    XCTAssertNil(claimsSet.subject)
    XCTAssertEqual(claimsSet.audience, [])
    XCTAssertNil(claimsSet.expirationTime)
    XCTAssertNil(claimsSet.notBeforeTime)
    XCTAssertNil(claimsSet.issueTime)
    XCTAssertNil(claimsSet.jwtID)
  }

  func testParseWhenInvalidIssuerType() {
    let json: [String: Any] = ["iss": 123]

    XCTAssertThrowsError(try JWTClaimsSet.parse(json)) { error in
      XCTAssertTrue(error.localizedDescription.contains("iss"))
    }
  }

  func testParseWhenInvalidSubjectType() {
    let json: [String: Any] = ["sub": 456]

    XCTAssertThrowsError(try JWTClaimsSet.parse(json)) { error in
      XCTAssertTrue(error.localizedDescription.contains("sub"))
    }
  }

  func testParseWhenInvalidJWTIDType() {
    let json: [String: Any] = ["jti": false]

    XCTAssertThrowsError(try JWTClaimsSet.parse(json)) { error in
      XCTAssertTrue(error.localizedDescription.contains("jti"))
    }
  }

  func testParseWhenInvalidAudienceList() {
    let json: [String: Any] = ["aud": [123, true]]

    XCTAssertThrowsError(try JWTClaimsSet.parse(json)) { error in
      XCTAssertTrue(error.localizedDescription.contains("aud"))
    }
  }

  func testParseJSONStringWhenValid() throws {
    let timestamp = Int64(Date().timeIntervalSince1970)
    let jsonString = """
          {
              "iss": "issuer",
              "aud": ["aud1"],
              "exp": \(timestamp)
          }
          """

    let claimsSet = try JWTClaimsSet.parse(jsonString)

    XCTAssertEqual(claimsSet.issuer, "issuer")
    XCTAssertEqual(claimsSet.audience, [])
    XCTAssertNotNil(claimsSet.expirationTime)
  }

  func testParseJSONStringWhenInvalidJSON() {
    let invalidJSONString = """
          { invalid json }
          """

    XCTAssertThrowsError(try JWTClaimsSet.parse(invalidJSONString))
  }
}
