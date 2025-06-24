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
import Foundation
import XCTest
import JOSESwift
import SwiftyJSON

@testable import SiopOpenID4VP

final class JWTDecoderTests: XCTestCase {
  func testDecodeJWT_AllFieldsDecodedCorrectly() {
    let payload: [String: Any] = [
      "response_type": "code",
      "response_uri": "https://response.uri",
      "redirect_uri": "https://redirect.uri",
      "presentation_definition": "{\"def123\": \"test\"}",
      "presentation_definition_uri": "https://definition.uri",
      "dcql_query": ["foo": "bar"],
      "request": "requestToken",
      "request_uri": "https://request.uri",
      "request_uri_method": "GET",
      "client_metadata": ["foo": "bar"],
      "client_id": "client123",
      "client_metadata_uri": "https://metadata.uri",
      "client_id_scheme": "dns",
      "nonce": "abc123",
      "scope": "openid",
      "response_mode": "fragment",
      "state": "xyz",
      "id_token_type": "subject_signed",
      "supported_algorithm": "ES256",
      "transaction_data": ["txn1", "txn2"],
      "verifier_attestations": [
        [
          "format": "jwt",
          "data": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...abc123",
          "credential_ids": ["id_card"]
        ],
        [
          "format": "jwt",
          "data": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...xyz456"
        ]
      ]
    ]

    let payloadData = try! JSONSerialization.data(withJSONObject: payload)
    let base64Payload = payloadData.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
    let jwt = "header.\(base64Payload).signature"

    guard let result = JWTDecoder.decodeJWT(jwt) else {
      XCTFail("Decoding returned nil")
      return
    }

    XCTAssertEqual(result.responseType, "code")
    XCTAssertEqual(result.responseUri, "https://response.uri")
    XCTAssertEqual(result.redirectUri, "https://redirect.uri")
    XCTAssertEqual(result.presentationDefinition, "{\"def123\": \"test\"}")
    XCTAssertEqual(result.presentationDefinitionUri, "https://definition.uri")
    XCTAssertEqual(result.dcqlQuery?["foo"].string, "bar")
    XCTAssertEqual(result.request, "requestToken")
    XCTAssertEqual(result.requestUri, "https://request.uri")
    XCTAssertEqual(result.requestUriMethod, "GET")
    XCTAssertEqual(result.clientMetaData!.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression), "{\"foo\":\"bar\"}")
    XCTAssertEqual(result.clientId, "client123")
    XCTAssertEqual(result.clientMetadataUri, "https://metadata.uri")
    XCTAssertEqual(result.clientIdScheme, "dns")
    XCTAssertEqual(result.nonce, "abc123")
    XCTAssertEqual(result.scope, "openid")
    XCTAssertEqual(result.responseMode, "fragment")
    XCTAssertEqual(result.state, "xyz")
    XCTAssertEqual(result.idTokenType, "subject_signed")
    XCTAssertEqual(result.supportedAlgorithm, "ES256")
    XCTAssertEqual(result.transactionData, ["txn1", "txn2"])
    XCTAssertEqual(result.verifierAttestations?.count, 2)

    let first = result.verifierAttestations?[0]
    XCTAssertEqual(first?["format"].string, "jwt")
    XCTAssertEqual(first?["data"].string, "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...abc123")
    XCTAssertEqual(first?["credential_ids"].arrayValue.map { $0.string! }, ["id_card"])

    let second = result.verifierAttestations?[1]
    XCTAssertEqual(second?["format"].string, "jwt")
    XCTAssertEqual(second?["data"].string, "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...xyz456")
    XCTAssertNil(second?["credential_ids"].array)  
  }
}
