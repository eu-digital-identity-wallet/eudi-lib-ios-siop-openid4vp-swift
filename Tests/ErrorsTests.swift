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
@testable import SiopOpenID4VP

class ErrorTests: XCTestCase {
  
  func testUnsupportedResponseType() {
    let error = AuthorizationError.unsupportedResponseType(type: "code")
    XCTAssertEqual(error.errorDescription, ".unsupportedResponseType code")
  }

  func testMissingResponseType() {
    let error = AuthorizationError.missingResponseType
    XCTAssertEqual(error.errorDescription, ".invalidScopes")
  }

  func testMissingPresentationDefinition() {
    let error = AuthorizationError.missingPresentationDefinition
    XCTAssertEqual(error.errorDescription, ".missingPresentationDefinition")
  }

  func testNonHttpsPresentationDefinitionUri() {
    let error = AuthorizationError.nonHttpsPresentationDefinitionUri
    XCTAssertEqual(error.errorDescription, ".nonHttpsPresentationDefinitionUri")
  }

  func testUnsupportedURLScheme() {
    let error = AuthorizationError.unsupportedURLScheme
    XCTAssertEqual(error.errorDescription, ".unsupportedURLScheme")
  }

  func testUnsupportedResolution() {
    let error = AuthorizationError.unsupportedResolution
    XCTAssertEqual(error.errorDescription, ".unsupportedResolution")
  }

  func testInvalidState() {
    let error = AuthorizationError.invalidState
    XCTAssertEqual(error.errorDescription, ".invalidState")
  }

  func testInvalidResponseMode() {
    let error = AuthorizationError.invalidResponseMode
    XCTAssertEqual(error.errorDescription, ".invalidResponseMode")
  }
  
  func testUnsupportedClientIdScheme() {
    let error = ValidatedAuthorizationError.unsupportedClientIdScheme("http")
    XCTAssertEqual(error.errorDescription, ".unsupportedClientIdScheme http")
  }

  func testValidationUnsupportedResponseType() {
    let error = ValidatedAuthorizationError.unsupportedResponseType("token")
    XCTAssertEqual(error.errorDescription, ".unsupportedResponseType Optional(\"token\")")
  }

  func testUnsupportedResponseMode() {
    let error = ValidatedAuthorizationError.unsupportedResponseMode(nil)
    XCTAssertEqual(error.errorDescription, ".unsupportedResponseMode ")
  }

  func testUnsupportedIdTokenType() {
    let error = ValidatedAuthorizationError.unsupportedIdTokenType("access_token")
    XCTAssertEqual(error.errorDescription, ".unsupportedIdTokenType access_token")
  }

  func testInvalidResponseType() {
    let error = ValidatedAuthorizationError.invalidResponseType
    XCTAssertEqual(error.errorDescription, "")
  }

  func testInvalidIdTokenType() {
    let error = ValidatedAuthorizationError.invalidIdTokenType
    XCTAssertEqual(error.errorDescription, ".invalidResponseType")
  }

  func testNoAuthorizationData() {
    let error = ValidatedAuthorizationError.noAuthorizationData
    XCTAssertEqual(error.errorDescription, ".noAuthorizationData")
  }

  func testInvalidAuthorizationData() {
    let error = ValidatedAuthorizationError.invalidAuthorizationData
    XCTAssertEqual(error.errorDescription, "")
  }

  func testInvalidPresentationDefinition() {
    let error = ValidatedAuthorizationError.invalidPresentationDefinition
    XCTAssertEqual(error.errorDescription, ".invalidAuthorizationData")
  }

  func testInvalidClientMetadata() {
    let error = ValidatedAuthorizationError.invalidClientMetadata
    XCTAssertEqual(error.errorDescription, ".invalidClientMetadata")
  }

  func testMissingRequiredField() {
    let error = ValidatedAuthorizationError.missingRequiredField("scope")
    XCTAssertEqual(error.errorDescription, ".missingRequiredField scope")
  }

  func testInvalidJwtPayload() {
    let error = ValidatedAuthorizationError.invalidJwtPayload
    XCTAssertEqual(error.errorDescription, ".invalidJwtPayload")
  }

  func testInvalidRequestUri() {
    let error = ValidatedAuthorizationError.invalidRequestUri("http://example.com")
    XCTAssertEqual(error.errorDescription, ".invalidRequestUri http://example.com")
  }

  func testConflictingData() {
    let error = ValidatedAuthorizationError.conflictingData
    XCTAssertEqual(error.errorDescription, ".conflictingData")
  }

  func testInvalidRequest() {
    let error = ValidatedAuthorizationError.invalidRequest
    XCTAssertEqual(error.errorDescription, ".invalidRequest")
  }

  func testNotSupportedOperation() {
    let error = ValidatedAuthorizationError.notSupportedOperation
    XCTAssertEqual(error.errorDescription, ".notSupportedOperation")
  }

  func testInvalidFormat() {
    let error = ValidatedAuthorizationError.invalidFormat
    XCTAssertEqual(error.errorDescription, ".invalidFormat")
  }

  func testUnsupportedConsent() {
    let error = ValidatedAuthorizationError.unsupportedConsent
    XCTAssertEqual(error.errorDescription, ".unsupportedConsent")
  }

  func testNegativeConsent() {
    let error = ValidatedAuthorizationError.negativeConsent
    XCTAssertEqual(error.errorDescription, ".negativeConsent")
  }
  
  func testInvalidSource() {
    let error = ResolvingError.invalidSource
    XCTAssertEqual(error.errorDescription, ".invalidSource")
  }

  func testInvalidScopes() {
    let error = ResolvingError.invalidScopes
    XCTAssertEqual(error.errorDescription, ".invalidScopes")
  }
  
  func testInvalidClientData() {
    let error = ResolvedAuthorisationError.invalidClientData
    XCTAssertEqual(error.errorDescription, ".invalidClientData")
  }

  func testInvalidPresentationDefinitionData() {
    let error = ResolvedAuthorisationError.invalidPresentationDefinitionData
    XCTAssertEqual(error.errorDescription, ".invalidPresentationDefinitionData")
  }

  func testResolvedUnsupportedResponseType() {
    let error = ResolvedAuthorisationError.unsupportedResponseType("code")
    XCTAssertEqual(error.errorDescription, ".unsupportedResponseType code")
  }
  
  func testErrorDescription() {
    // .invalidUrl
    let invalidUrlError = FetchError.invalidUrl
    XCTAssertEqual(invalidUrlError.errorDescription, ".invalidUrl")

    // .networkError
    let networkError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network error occurred"])
    let networkFetchError = FetchError.networkError(networkError)
    XCTAssertEqual(networkFetchError.errorDescription, ".networkError Network error occurred")

    // .invalidResponse
    let invalidResponseError = FetchError.invalidResponse
    XCTAssertEqual(invalidResponseError.errorDescription, ".invalidResponse")

    // .decodingError
    let decodingError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Decoding error occurred"])
    let decodingFetchError = FetchError.decodingError(decodingError)
    XCTAssertEqual(decodingFetchError.errorDescription, ".decodingError Decoding error occurred")
  }
}

class JOSEErrorTests: XCTestCase {
    
  func testErrorDescription() {
    XCTAssertEqual(JOSEError.notSupportedRequest.errorDescription, ".notSupportedRequest")
    XCTAssertEqual(JOSEError.invalidIdTokenRequest.errorDescription, ".invalidIdTokenRequest")
    XCTAssertEqual(JOSEError.invalidPublicKey.errorDescription, ".invalidPublicKey")
    XCTAssertEqual(JOSEError.invalidJWS.errorDescription, ".invalidJWS")
    XCTAssertEqual(JOSEError.invalidSigner.errorDescription, ".invalidSigner")
    XCTAssertEqual(JOSEError.invalidVerifier.errorDescription, ".invalidVerifier")
    XCTAssertEqual(JOSEError.invalidDidIdentifier.errorDescription, ".invalidDidIdentifier")
  }
}

class DispatchOutcomeTests: XCTestCase {

  func testInit() {
    let outcome = DispatchOutcome()
    XCTAssertEqual(outcome, .accepted(redirectURI: nil))
  }
  
  func testInitFromDecoder_accepted() throws {
    let json = """
    { "accepted": "https://www.example.com" }
    """
    let data = Data(json.utf8)
    let decoder = JSONDecoder()
    
    let outcome = try decoder.decode(DispatchOutcome.self, from: data)
    XCTAssertEqual(outcome, .accepted(redirectURI: URL(string: "https://www.example.com")))
  }
  
  func testInitFromDecoder_rejected() throws {
    let json = """
    { "rejected": "reason" }
    """
    let data = Data(json.utf8)
    let decoder = JSONDecoder()
    
    let outcome = try decoder.decode(DispatchOutcome.self, from: data)
    XCTAssertEqual(outcome, .rejected(reason: "reason"))
  }
  
  func testInitFromDecoder_invalid() throws {
    let json = """
    { "unknown": "value" }
    """
    let data = Data(json.utf8)
    let decoder = JSONDecoder()
    
    XCTAssertThrowsError(try decoder.decode(DispatchOutcome.self, from: data))
  }
  
  func testEncode() throws {
    let outcome = DispatchOutcome.accepted(redirectURI: URL(string: "https://www.example.com"))
    let encoder = JSONEncoder()
    
    let data = try encoder.encode(outcome)
    let decodedOutcome = try JSONDecoder().decode(DispatchOutcome.self, from: data)
    
    XCTAssertEqual(decodedOutcome, outcome)
  }
}
