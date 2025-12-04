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

class VpTokenTests: XCTestCase {
  func testVpTokenEncodingWithSingleGenericPresentation() throws {
    let presentation = VerifiablePresentation.generic("test_presentation_string")
    let token = VpToken(verifiablePresentations: [presentation])

    let encoder = JSONEncoder()
    let data = try encoder.encode(token)

    let jsonString = String(data: data, encoding: .utf8)
    XCTAssertEqual(jsonString, "\"test_presentation_string\"")
  }

  func testVpTokenEncodingWithSingleJsonPresentation() throws {
    let jsonPresentation = JSON(["type": "test", "id": "test_id"])
    let presentation = VerifiablePresentation.json(jsonPresentation)
    let token = VpToken(verifiablePresentations: [presentation])

    let encoder = JSONEncoder()
    let data = try encoder.encode(token)

    let decodedJson = try JSON(data: data)
    XCTAssertEqual(decodedJson["type"].stringValue, "test")
    XCTAssertEqual(decodedJson["id"].stringValue, "test_id")
  }

  func testVpTokenEncodingWithMultiplePresentations() throws {
    let p1 = VerifiablePresentation.generic("vp1")
    let p2 = VerifiablePresentation.json(JSON(["vp": "vp2"]))

    let token = VpToken(verifiablePresentations: [p1, p2])

    let encoder = JSONEncoder()
    let data = try encoder.encode(token)

    let decodedJson = try JSON(data: data)
    XCTAssertEqual(decodedJson.arrayValue[0].stringValue, "vp1")
    XCTAssertEqual(decodedJson.arrayValue[1]["vp"].stringValue, "vp2")
  }

  func testVpTokenEncodingWithEmptyPresentations() {
    let token = VpToken(verifiablePresentations: [])
    let encoder = JSONEncoder()

    XCTAssertThrowsError(try encoder.encode(token)) { error in
      XCTAssertEqual(error as? VpTokenError, .notExpected)
    }
  }
}
