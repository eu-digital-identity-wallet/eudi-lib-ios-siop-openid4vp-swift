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

@testable import OpenID4VP

final class UnvalidatedRequestTests: XCTestCase {

  // MARK: - Helpers

  func url(_ query: String) -> String {
    return "https://example.com/authorize?\(query)"
  }

  func encodeJSON(_ object: Any) -> String {
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: []),
          let jsonString = String(data: data, encoding: .utf8) else {
      return ""
    }
    return jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
  }

  // MARK: - Tests

  func testPlainRequest_successfullyParses() {
    let query = [
      "client_id=abc123",
      "response_type=code",
      "scope=openid",
      "nonce=xyz",
      "presentation_definition=\(encodeJSON(["input": "something"]))",
      "dcql_query=\(encodeJSON(["query": "foo"]))",
      "transaction_data=\(encodeJSON(["tx1", "tx2"]))"
    ].joined(separator: "&")

    let result = UnvalidatedRequest.make(from: url(query))

    switch result {
    case .success(.plain(let object)):
      XCTAssertEqual(object.clientId, "abc123")
      XCTAssertEqual(object.responseType, "code")
      XCTAssertEqual(object.scope, "openid")
      XCTAssertEqual(object.nonce, "xyz")
      XCTAssertEqual(object.transactionData, ["tx1", "tx2"])
    default:
      XCTFail("Expected plain request to succeed")
    }
  }

  func testJwtSecuredPassByValue_successfullyParses() {
    let query = "client_id=abc123&request=some.jwt.token"
    let result = UnvalidatedRequest.make(from: url(query))

    switch result {
    case .success(.jwtSecuredPassByValue(let clientId, let jwt)):
      XCTAssertEqual(clientId, "abc123")
      XCTAssertEqual(jwt, "some.jwt.token")
    default:
      XCTFail("Expected jwtSecuredPassByValue to succeed")
    }
  }

  func testJwtSecuredPassByReference_withMethod_successfullyParses() {
    let query = "client_id=abc123&request_uri=https://example.com/jar.jwt&request_uri_method=POST"
    let result = UnvalidatedRequest.make(from: url(query))

    switch result {
    case .success(.jwtSecuredPassByReference(let clientId, let jwtURI, let method)):
      XCTAssertEqual(clientId, "abc123")
      XCTAssertEqual(jwtURI.absoluteString, "https://example.com/jar.jwt")
      XCTAssertEqual(method, .POST)
    default:
      XCTFail("Expected jwtSecuredPassByReference to succeed")
    }
  }

  func testJwtSecuredPassByReference_withoutMethod_successfullyParses() {
    let query = "client_id=abc123&request_uri=https://example.com/jar.jwt"
    let result = UnvalidatedRequest.make(from: url(query))

    switch result {
    case .success(.jwtSecuredPassByReference(let clientId, let jwtURI, let method)):
      XCTAssertEqual(clientId, "abc123")
      XCTAssertEqual(jwtURI.absoluteString, "https://example.com/jar.jwt")
      XCTAssertNil(method)
    default:
      XCTFail("Expected jwtSecuredPassByReference to succeed")
    }
  }

  func testError_whenBothRequestAndRequestUriProvided() {
    let query = "client_id=abc123&request=token&request_uri=https://example.com/jar"
    let result = UnvalidatedRequest.make(from: url(query))

    guard case .failure(let error as ValidationError) = result else {
      return XCTFail("Expected failure with ValidationError")
    }
    XCTAssertEqual(error, .invalidUseOfBothRequestAndRequestUri)
  }

  func testError_whenMissingClientId() {
    let query = "request=token"
    let result = UnvalidatedRequest.make(from: url(query))

    guard case .failure(let error as ValidationError) = result else {
      return XCTFail("Expected failure with ValidationError")
    }
    XCTAssertEqual(error, .missingClientId)
  }

  func testError_whenInvalidRequestUriMethod() {
    let query = "client_id=abc123&request_uri=https://example.com/jar&request_uri_method=INVALID"
    let result = UnvalidatedRequest.make(from: url(query))

    guard case .failure(let error as ValidationError) = result else {
      return XCTFail("Expected failure with ValidationError")
    }
    XCTAssertEqual(error, .invalidRequestUriMethod)
  }

  func testPlainRequest_withVerifierInfo_successfullyParses() {
    let query = [
      "client_id=abc123",
      "response_type=code",
      "scope=openid",
      "nonce=xyz",
      "presentation_definition=\(encodeJSON(["input": "something"]))",
      "dcql_query=\(encodeJSON(["query": "foo"]))",
      "transaction_data=\(encodeJSON(["tx1", "tx2"]))",
      "verifier_info=\(encodeJSON([["foo": "bar"]]))"
    ].joined(separator: "&")

    let result = UnvalidatedRequest.make(from: url(query))

    switch result {
    case .success(.plain(let object)):
      XCTAssertEqual(object.clientId, "abc123")
      XCTAssertEqual(object.responseType, "code")
      XCTAssertEqual(object.scope, "openid")
      XCTAssertEqual(object.nonce, "xyz")
      XCTAssertEqual(object.transactionData, ["tx1", "tx2"])
      XCTAssertEqual(object.verifierInfo?.first?["foo"].stringValue, "bar")
    default:
      XCTFail("Expected plain request with verifier_info to succeed")
    }
  }
}
