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
}
