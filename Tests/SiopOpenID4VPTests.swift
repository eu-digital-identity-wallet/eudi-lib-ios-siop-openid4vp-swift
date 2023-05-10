import Foundation
import XCTest

@testable import OpenID4VP

final class SiopOpenID4VPTests: XCTestCase {
 
  // MARK: - Resolved Validated Authorisation Request Testing
  
  func testValidationResolutionGivenDataIsValid() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? ValidatedSiopOpenId4VPRequest(authorizationRequestData: authorizationRequestData!)
    
    XCTAssertNotNil(validatedAuthorizationRequestData)
    
    let resolvedSiopOpenId4VPRequestData = try? await ResolvedSiopOpenId4VPRequestData(clientMetaDataResolver: ClientMetaDataResolver(), presentationDefinitionResolver: PresentationDefinitionResolver(), validatedAuthorizationRequest: validatedAuthorizationRequestData!)
    
    XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
  }
  
  func testValidationResolutionWithAuthorisationRequestGivenDataIsValid() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let authorizationRequest = try? await AuthorizationRequest(authorizationRequestData: authorizationRequestData!)
    
    XCTAssertNotNil(authorizationRequest)
    
    switch authorizationRequest {
    case .oauth2(let resolved):
      switch resolved {
      case .vpToken:
        XCTAssert(true)
      default:
        XCTAssert(false, "Invalid resolution")
      }
    default:
      XCTAssert(false, "Invalid resolution")
    }
  }
  
  // MARK: - Invalid data Testing
  
  func testAuthorisationValidationGivenDataIsInvalid() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.invalidUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    do {
      _ = try ValidatedSiopOpenId4VPRequest(authorizationRequestData: authorizationRequestData!)
    } catch let error as ValidatedAuthorizationError {
      switch error {
      case ValidatedAuthorizationError.unsupportedResponseType:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
      return
    } catch {
      XCTAssert(false)
    }
    
    XCTAssert(false)
  }
  
  func testSDKValidationResolutionGivenDataByValueIsValid() async throws {
    
    let sdk = SiopOpenID4VP()
    let presentationDefinition = try await sdk.process(url: TestsConstants.validByClientByValuePresentationByReferenceUrl)
    
    XCTAssert(presentationDefinition.id == "32f54163-7166-48f1-93d8-ff217bdb0653")
    XCTAssert(presentationDefinition.inputDescriptors.count == 1)
  }
  
  func testJWT() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? ValidatedSiopOpenId4VPRequest(
      request: TestsConstants.passByValueJWT
    )
    
    XCTAssertNotNil(validatedAuthorizationRequestData)
    
    let resolvedSiopOpenId4VPRequestData = try? await ResolvedSiopOpenId4VPRequestData(
      clientMetaDataResolver: ClientMetaDataResolver(),
      presentationDefinitionResolver: PresentationDefinitionResolver(),
      validatedAuthorizationRequest: validatedAuthorizationRequestData!
    )
    
    XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
    
    switch resolvedSiopOpenId4VPRequestData! {
    case .vpToken:
      XCTAssert(true)
    default:
      XCTAssert(false)
    }
  }
}
