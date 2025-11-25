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
import Foundation
import SwiftyJSON

@testable import OpenID4VP

final class VerifierAttestationTests: XCTestCase {

  func testInitWithAllParametersShouldStoreValuesCorrectly() throws {
    let id = try QueryId(value: "cred1")
    let jsonData = JSON(["someKey": "someValue"])

    let attestation = VerifierInfo(
      format: "jwt",
      data: jsonData,
      credentialIds: [id]
    )

    XCTAssertEqual(attestation.format, "jwt")
    XCTAssertEqual(attestation.data, jsonData)
    XCTAssertEqual(attestation.credentialIds, [id])
  }

  func testInitWithNoCredentialIdsShouldDefaultToNil() throws {
    let jsonData = JSON(["payload": "xyz"])
    let attestation = VerifierInfo(format: "jwt", data: jsonData)

    XCTAssertNil(attestation.credentialIds)
  }

  func testFromValidJsonShouldParseSuccessfully() throws {
    let rawJSON: JSON = [
      "format": "jwt",
      "data": ["payload": "abc"],
      "credentialIds": ["id1", "id2"]
    ]

    let attestation = try VerifierInfo.from(json: rawJSON)

    XCTAssertEqual(attestation.format, "jwt")
    XCTAssertEqual(attestation.data["payload"].stringValue, "abc")
    XCTAssertEqual(attestation.credentialIds?.map(\.value), ["id1", "id2"])
  }

  func testFromMissingFormatShouldThrow() {
    let rawJSON: JSON = [
      "data": ["payload": "xyz"]
    ]

    XCTAssertThrowsError(try VerifierInfo.from(json: rawJSON)) { error in
      guard
        let validationError = error as? ValidationError
      else {
        XCTFail("Expected ValidationError but got \(error)")
        return
      }

      XCTAssertEqual(validationError, .invalidVerifierAttestationFormat)
    }
  }

  func testFromInvalidCredentialIdsShouldThrow() {
    let rawJSON: JSON = [
      "format": "ldp",
      "data": [:],
      "credentialIds": [""]
    ]

    XCTAssertThrowsError(try VerifierInfo.from(json: rawJSON))
  }

  func testCodableRoundTrip() throws {
    let id1 = try QueryId(value: "credX")
    let json = JSON(["meta": "info"])

    let original = VerifierInfo(format: "jwt", data: json, credentialIds: [id1])

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    let encoded = try encoder.encode(original)
    let decoded = try decoder.decode(VerifierInfo.self, from: encoded)

    XCTAssertEqual(decoded, original)
  }
  
  func testValidAttestationShouldPass() throws {

    let queryId = try QueryId(value: "cred-1")
    let format = try Format(format: "jwt")

    let credential = try CredentialQuery(
      id: queryId,
      format: format,
      meta: [:]
    )

    let attestation = VerifierInfo(
      format: "jwt",
      data: JSON(["some": "value"]),
      credentialIds: [queryId]
    )

    let dcql = try DCQL(credentials: [credential])
    let query = PresentationQuery.byDigitalCredentialsQuery(dcql)

    let result = try VerifierInfo.validatedVerifierInfo(
      [attestation],
      presentationQuery: query
    )

    XCTAssertEqual(result, [attestation])
  }

  func testNilAttestationsShouldReturnNil() throws {
    let queryId = try QueryId(value: "cred-1")
    let format = try Format(format: "jwt")

    let credential = try CredentialQuery(
      id: queryId,
      format: format,
      meta: [:]
    )

    let query = PresentationQuery.byDigitalCredentialsQuery(
      try DCQL(credentials: [credential])
    )

    let result = try VerifierInfo.validatedVerifierInfo(
      nil,
      presentationQuery: query
    )

    XCTAssertNil(result)
  }
  
  func testEmptyCredentialIdsShouldPass() throws {
    let credential = try CredentialQuery(
      id: QueryId(value: "cred-a"),
      format: try Format(format: "jwt"),
      meta: [:]
    )

    let attestation = VerifierInfo(
      format: "jwt",
      data: JSON(["key": "value"]),
      credentialIds: nil // applies to all
    )

    let query = PresentationQuery.byDigitalCredentialsQuery(
      try DCQL(credentials: [credential])
    )

    let result = try VerifierInfo.validatedVerifierInfo(
      [attestation],
      presentationQuery: query
    )

    XCTAssertEqual(result, [attestation])
  }
  
  func testInvalidCredentialIdShouldThrow() throws {
    let validId = try QueryId(value: "cred-1")
    let invalidId = try QueryId(value: "nonexistent")

    let credential = try CredentialQuery(
      id: validId,
      format: try Format(format: "jwt"),
      meta: [:]
    )

    let attestation = VerifierInfo(
      format: "jwt",
      data: JSON(["field": "value"]),
      credentialIds: [invalidId]
    )

    let query = PresentationQuery.byDigitalCredentialsQuery(
      try DCQL(credentials: [credential])
    )

    XCTAssertThrowsError(
      try VerifierInfo.validatedVerifierInfo([attestation], presentationQuery: query)
    ) { error in
      XCTAssertEqual(error as? ValidationError, .invalidVerifierAttestationCredentialIds)
    }
  }
}
