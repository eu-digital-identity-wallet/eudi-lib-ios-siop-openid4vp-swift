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

@testable import OpenID4VP

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
      "supported_algorithm": "ES256",
      "transaction_data": ["txn1", "txn2"],
      "verifier_info": [
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
    XCTAssertEqual(result.supportedAlgorithm, "ES256")
    XCTAssertEqual(result.transactionData, ["txn1", "txn2"])
    XCTAssertEqual(result.verifierInfo?.count, 2)
    
    let first = result.verifierInfo?[0]
    XCTAssertEqual(first?["format"].string, "jwt")
    XCTAssertEqual(first?["data"].string, "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...abc123")
    XCTAssertEqual(first?["credential_ids"].arrayValue.map { $0.string! }, ["id_card"])
    
    let second = result.verifierInfo?[1]
    XCTAssertEqual(second?["format"].string, "jwt")
    XCTAssertEqual(second?["data"].string, "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...xyz456")
    XCTAssertNil(second?["credential_ids"].array)
  }
  
  /// Builds a compact JWS `header.payload.signature` with URL-safe Base64 (no padding).
  private func makeJWT(
    header: [String: Any] = ["alg": "none", "typ": "JWT"],
    payload: [String: Any],
    signature: String = "sig" // arbitrary; decoder ignores it
  ) throws -> String {
    func jsonData(_ obj: Any) throws -> Data {
      try JSONSerialization.data(withJSONObject: obj, options: [])
    }
    func base64url(_ data: Data) -> String {
      let b64 = data.base64EncodedString()
      // URL-safe, strip padding per JWT spec
      return b64
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
    }
    
    let headerPart = base64url(try jsonData(header))
    let payloadPart = base64url(try jsonData(payload))
    return [headerPart, payloadPart, signature].joined(separator: ".")
  }
  
  // MARK: - decodeJWT tests
  
  func testDecodeJWT_returnsNil_whenFewerThanTwoSegments() {
    XCTAssertNil(JWTDecoder.decodeJWT(""), "Empty should be nil")
    XCTAssertNil(JWTDecoder.decodeJWT("onlyone"), "Single segment should be nil")
    XCTAssertNil(JWTDecoder.decodeJWT("."), "Dot with empty parts still <2 segments after split behavior")
  }
  
  func testDecodeJWT_allowsThreeSegments_andDecodesPayload() throws {
    let jwt = try makeJWT(payload: ["sub": "user123", "iat": 1_700_000_000])
    XCTAssertNotNil(JWTDecoder.decodeJWT(jwt))
  }
  
  func testDecodeJWT_supportsURLSafeBase64WithoutPadding() throws {
    // Craft a length that typically needs padding in standard Base64
    let jwt = try makeJWT(payload: ["role": "admin", "aud": "example"])
    XCTAssertNotNil(JWTDecoder.decodeJWT(jwt))
  }
  
  func testDecodeJWT_ignoresSignatureContent() throws {
    let jwt = try makeJWT(payload: ["ok": true], signature: "!!!not-a-real-signature!!!")
    XCTAssertNotNil(JWTDecoder.decodeJWT(jwt))
  }
  
  func testDecodeJWT_returnsNil_whenPayloadIsNotBase64() {
    // header . invalidBase64 . signature
    let header = "eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0" // {"alg":"none","typ":"JWT"} w/o padding
    let jwt = "\(header).not_base64!!.\("x")"
    XCTAssertNil(JWTDecoder.decodeJWT(jwt))
  }
  
  func testDecodeJWT_returnsNil_whenPayloadIsNotValidJSON() throws {
    // Base64url of non-JSON bytes
    let bad = Data([0xFF, 0xFE, 0xFD, 0x00, 0x01])
    let b64 = bad.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
    let header = "eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0"
    let jwt = "\(header).\(b64).sig"
    XCTAssertNil(JWTDecoder.decodeJWT(jwt))
  }
  
  func testDecodeJWT_handlesLargePayload() throws {
    let claims = (0..<200).reduce(into: [String: Any]()) { $0["k\($1)"] = "v\($1)" }
    let jwt = try makeJWT(payload: claims)
    XCTAssertNotNil(JWTDecoder.decodeJWT(jwt))
  }
  
  func testDecodeJWT_allowsEmptySignatureSegment() throws {
    // header.payload.  (trailing dot)
    let base = try makeJWT(payload: ["x": 1])
    let noSig = base.split(separator: ".").prefix(2).joined(separator: ".") + "."
    XCTAssertNotNil(JWTDecoder.decodeJWT(noSig))
  }
}
