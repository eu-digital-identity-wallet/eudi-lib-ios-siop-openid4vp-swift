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
import X509
import SwiftyJSON
@testable import OpenID4VP

class ClientTests: XCTestCase {

  func testClientIdPreRegistered() {
    let client = Client.preRegistered(clientId: "client123", legalName: "John Doe")
    let id = client.id

    XCTAssertEqual(id.scheme, .preRegistered)
    XCTAssertEqual(id.originalClientId, "client123")
  }

  func testClientIdRedirectUri() throws {
    let client = Client.redirectUri(clientId: "client123")
    let id = client.id

    XCTAssertEqual(id.scheme, .redirectUri)
  }

  func testLegalNamePreRegistered() {
    let client = Client.preRegistered(clientId: "id", legalName: "John Doe")

    XCTAssertEqual(client.legalName, "John Doe")
  }

  func testLegalNameRedirectUri() {
    let client = Client.redirectUri(clientId: "client123")
    XCTAssertNil(client.legalName)
  }
}

final class ClientIdSchemeTests: XCTestCase {

  func testRawValueInitialization() {
    XCTAssertEqual(ClientIdPrefix(rawValue: "pre-registered"), .preRegistered)
    XCTAssertEqual(ClientIdPrefix(rawValue: "redirect_uri"), .redirectUri)
    XCTAssertEqual(ClientIdPrefix(rawValue: "openid_federation"), .openidFederation)
    XCTAssertEqual(ClientIdPrefix(rawValue: "decentralized_identifier"), .decentralizedIdentifier)
    XCTAssertEqual(ClientIdPrefix(rawValue: "x509_san_dns"), .x509SanDns)
    XCTAssertEqual(ClientIdPrefix(rawValue: "verifier_attestation"), .verifierAttestation)
  }

  func testRawValueInitializationForInvalidValue() {
    XCTAssertNil(ClientIdPrefix(rawValue: "unknown"))
    XCTAssertNil(ClientIdPrefix(rawValue: "invalid_value"))
  }

  func testInitFromAuthorizationRequestObjectWithValidScheme() throws {
    let validSchemes = [
      "pre-registered", "redirect_uri", "openid_federation",
      "decentralized_identifier", "x509_san_dns", "verifier_attestation"
    ]

    for scheme in validSchemes {
      let json = JSON(["client_id_scheme": scheme])
      let clientIdScheme = try ClientIdPrefix(authorizationRequestObject: json)
      XCTAssertEqual(clientIdScheme.rawValue, scheme)
    }
  }

  func testInitFromAuthorizationRequestObjectWithMissingKey() {
    let json = JSON([:])
    XCTAssertThrowsError(try ClientIdPrefix(authorizationRequestObject: json)) { error in
      XCTAssertEqual(error as? ValidationError, .unsupportedClientIdScheme("unknown"))
    }
  }

  func testInitFromAuthorizationRequestObjectWithUnsupportedValue() {
    let json = JSON(["client_id_scheme": "custom_scheme"])
    XCTAssertThrowsError(try ClientIdPrefix(authorizationRequestObject: json)) { error in
      XCTAssertEqual(error as? ValidationError, .unsupportedClientIdScheme("custom_scheme"))
    }
  }
}
