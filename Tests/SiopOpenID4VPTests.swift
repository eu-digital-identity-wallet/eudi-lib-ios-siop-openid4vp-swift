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
}
