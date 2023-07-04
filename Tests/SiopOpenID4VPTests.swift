import Foundation
import Combine
import XCTest
import PresentationExchange

@testable import SiopOpenID4VP

final class SiopOpenID4VPTests: XCTestCase {
  
  var subscriptions = Set<AnyCancellable>()
  
  override func setUp() async throws {
    overrideDependencies()
    try await super.setUp()
  }
  
  override func tearDown() {
    DependencyContainer.shared.removeAll()
    super.tearDown()
  }
  
  // MARK: - Presentation submission test
  
  func testPresentationSubmissionJsonStringDecoding() throws {
    
    let definition = try! Dictionary.from(
      bundle: "presentation_submission_example"
    ).get().toJSONString()!
    
    let result: Result<PresentationSubmissionContainer, ParserError> = Parser().decode(json: definition)
    
    let container = try! result.get()
    
    XCTAssert(container.submission.id == "a30e3b91-fb77-4d22-95fa-871689c322e2")
  }
  
  // MARK: - Authorisation Request Testing
  
  func testAuthorizationRequestDataGivenValidDataInURL() throws {
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validAuthorizeUrl)
    XCTAssertNotNil(authorizationRequestData)
  }
  
  func testAuthorizationRequestDataGivenInvalidInput() throws {
  
    let parser = Parser()
    let result: Result<AuthorizationRequestUnprocessedData, ParserError> = parser.decode(
      path: "input_descriptors_example",
      type: "json"
    )
    
    let container = try? result.get()
    XCTAssertNotNil(container)
  }
  
  func testSDKValidationResolutionGivenDataByValueIsValid() async throws {
    
    let sdk = SiopOpenID4VP()
    let presentationDefinition: PresentationDefinition = try await sdk.process(url: TestsConstants.validAuthorizeUrl)
    
    XCTAssert(presentationDefinition.id == "8e6ad256-bd03-4361-a742-377e8cccced0")
    XCTAssert(presentationDefinition.inputDescriptors.count == 1)
  }
  
  func testSDKValidationResolutionGivenDataByReferenceIsValid() async throws {
    
    let sdk = SiopOpenID4VP()
    
    overrideDependencies()
    let presentationDefinition = try await sdk.process(url: TestsConstants.validByReferenceAuthorizeUrl)
    
    XCTAssert(presentationDefinition.id == "32f54163-7166-48f1-93d8-ff217bdb0653")
    XCTAssert(presentationDefinition.inputDescriptors.count == 1)
  }
  
  func testSDKValidationResolutionGivenDataIsInvalid() async throws {
    
    let sdk = SiopOpenID4VP()
    
    do {
      _ = try await sdk.process(url: TestsConstants.invalidAuthorizeUrl)
    } catch {
      XCTAssert(true, error.localizedDescription)
      return
    }
    
    XCTAssert(false)
  }
  
  func testSDKValidationResolutionAndDoNotMatchGivenDataByValueIsValid() async throws {
    
    let sdk = SiopOpenID4VP()
    let passportClaim = Claim(
      id: "samplePassport",
      format: .ldp,
      jsonObject: [
        "credentialSchema":
          [
            "id": "hub://did:foo:123/Collections/schema.us.gov/passport.json"
          ],
        "credentialSubject":
          [
            "birth_date":"1974-02-11",
          ]
        ]
      )
    
    let presentationDefinition = try await sdk.process(url: TestsConstants.validAuthorizeUrl)
    let match = sdk.match(presentationDefinition: presentationDefinition, claims: [passportClaim])
    
    XCTAssert(presentationDefinition.id == "8e6ad256-bd03-4361-a742-377e8cccced0")
    XCTAssert(presentationDefinition.inputDescriptors.count == 1)
    
    if case .notMatched = match {
      XCTAssert(true)
      
    } else {
      XCTFail("wrong match")
    }
  }
  
  // MARK: - Resolved Validated Authorisation Request Testing
  
  func testIdVpTokenValidationResolutionGivenReferenceDataIsValid() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validIdVpTokenByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? await ValidatedSiopOpenId4VPRequest(authorizationRequestData: authorizationRequestData!)
    
    XCTAssertNotNil(validatedAuthorizationRequestData)
    
    let resolvedSiopOpenId4VPRequestData = try? await ResolvedRequestData(clientMetaDataResolver: ClientMetaDataResolver(), presentationDefinitionResolver: PresentationDefinitionResolver(), validatedAuthorizationRequest: validatedAuthorizationRequestData!)
    
    XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
  }
  
  func testIdTokenValidationResolutionGivenReferenceDataIsValid() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validIdTokenByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? await ValidatedSiopOpenId4VPRequest(authorizationRequestData: authorizationRequestData!)
    
    XCTAssertNotNil(validatedAuthorizationRequestData)
    
    let resolvedSiopOpenId4VPRequestData = try? await ResolvedRequestData(clientMetaDataResolver: ClientMetaDataResolver(), presentationDefinitionResolver: PresentationDefinitionResolver(), validatedAuthorizationRequest: validatedAuthorizationRequestData!)
    
    XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
  }
  
  func testValidationResolutionGivenReferenceDataIsValid() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validVpTokenByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? await ValidatedSiopOpenId4VPRequest(authorizationRequestData: authorizationRequestData!)
    
    XCTAssertNotNil(validatedAuthorizationRequestData)
    
    let resolvedSiopOpenId4VPRequestData = try? await ResolvedRequestData(clientMetaDataResolver: ClientMetaDataResolver(), presentationDefinitionResolver: PresentationDefinitionResolver(), validatedAuthorizationRequest: validatedAuthorizationRequestData!)
    
    XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
  }
  
  func testValidationResolutionWithAuthorisationRequestGivenDataIsValid() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validVpTokenByClientByValuePresentationByReferenceUrl)
    
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
      _ = try await ValidatedSiopOpenId4VPRequest(authorizationRequestData: authorizationRequestData!)
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
  
  func testSDKValidationResolutionGivenByValueDataIsValid() async throws {
    
    let sdk = SiopOpenID4VP()
    let presentationDefinition = try await sdk.process(url: TestsConstants.validVpTokenByClientByValuePresentationByReferenceUrl)
    
    XCTAssert(presentationDefinition.id == "32f54163-7166-48f1-93d8-ff217bdb0653")
    XCTAssert(presentationDefinition.inputDescriptors.count == 1)
  }
  
  func testRequestObjectGivenValidJWT() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validVpTokenByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? ValidatedSiopOpenId4VPRequest(
      request: TestsConstants.passByValueJWT
    )
    
    XCTAssertNotNil(validatedAuthorizationRequestData)
    
    let resolvedSiopOpenId4VPRequestData = try? await ResolvedRequestData(
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
  
  func testRequestObjectGivenValidJWTUri() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validVpTokenByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? await ValidatedSiopOpenId4VPRequest(
      requestUri: TestsConstants.passByValueJWTURI
    )
    
    XCTAssertNotNil(validatedAuthorizationRequestData)
    
    let resolvedSiopOpenId4VPRequestData = try? await ResolvedRequestData(
      clientMetaDataResolver: ClientMetaDataResolver(),
      presentationDefinitionResolver: PresentationDefinitionResolver(),
      validatedAuthorizationRequest: validatedAuthorizationRequestData!
    )
    
    XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
    
    switch resolvedSiopOpenId4VPRequestData! {
    case .vpToken, .idToken:
      XCTAssert(true)
    default:
      XCTAssert(false)
    }
  }
  
  func testSDKValidationResolutionGivenDataRequestObjectByValueIsValid() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.requestObjectUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? await ValidatedSiopOpenId4VPRequest(
      authorizationRequestData: authorizationRequestData!
    )
    
    XCTAssertNotNil(validatedAuthorizationRequestData)
    
    let resolvedSiopOpenId4VPRequestData = try? await ResolvedRequestData(
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
  
  func testSDKValidationResolutionGivenDataRequestObjectByReferenceIsValid() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.requestUriUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try await ValidatedSiopOpenId4VPRequest(
      authorizationRequestData: authorizationRequestData!
    )
    
    XCTAssertNotNil(validatedAuthorizationRequestData)
    
    let resolvedSiopOpenId4VPRequestData = try? await ResolvedRequestData(
      clientMetaDataResolver: ClientMetaDataResolver(),
      presentationDefinitionResolver: PresentationDefinitionResolver(),
      validatedAuthorizationRequest: validatedAuthorizationRequestData
    )
    
    XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
    
    switch resolvedSiopOpenId4VPRequestData! {
    case .vpToken, .idToken:
      XCTAssert(true)
    default:
      XCTAssert(false)
    }
  }
  
  func testSDKValidationResolutionGivenDataRequestObjectByReferenceIsNotFoundURL() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.requestExpiredUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    do {
      _ = try await ValidatedSiopOpenId4VPRequest(
        authorizationRequestData: authorizationRequestData!
      )
    } catch let error as FetchError {
      print(error.localizedDescription)
      switch error {
      case .invalidStatusCode(_, let status):
        XCTAssert(status == 404)
        return
      default: break
      }
    } catch {
      XCTAssert(true)
      return
    }
    
    XCTAssert(false)
  }
  
  func testSDKInstanceValidationResolutionGivenDataRequestObjectByValueIsValid() async throws {
    
    let sdk = SiopOpenID4VP()
    let presentationDefinition = try? await sdk.process(url: TestsConstants.requestObjectUrl)
    
    XCTAssertNotNil(presentationDefinition!)
    
    XCTAssert(presentationDefinition!.id == "32f54163-7166-48f1-93d8-ff217bdb0653")
    XCTAssert(presentationDefinition!.inputDescriptors.count == 2)
    XCTAssert(presentationDefinition!.inputDescriptors.first!.constraints.fields.first!.paths.first == "$.credentialSchema.id")
  }
  
  func testSDKAuthorisationResolutionWithPublisherValidationResolutionGivenDataByReferenceIsValid() {
    
    let expectation = XCTestExpectation(description: "Authorisation request succesful")
            
    let sdk = SiopOpenID4VP()

    overrideDependencies()
    sdk.authorizationPublisher(for: TestsConstants.validByReferenceAuthorizeUrl)
      .sink { completion in
        switch completion {
        case .failure(let error):
          XCTFail("Authorisation request failed with error: \(error)")
        case .finished:
          expectation.fulfill()
        }
      } receiveValue: { value in
        switch value {
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
      }.store(in: &subscriptions)
    
    wait(for: [expectation], timeout: 5.0)
  }
  
  func testSDKAuthorisationValidationGivenDataByReferenceIsValid() async throws {
    
    let sdk = SiopOpenID4VP()

    overrideDependencies()
    let result = try await sdk.authorize(url: TestsConstants.validByReferenceAuthorizeUrl)
    
    switch result {
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
}

private extension SiopOpenID4VPTests {
  func overrideDependencies() {
    DependencyContainer.shared.register(type: Reporting.self, dependency: {
      MockReporter()
    })
  }
}
