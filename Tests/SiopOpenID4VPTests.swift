import Foundation
import XCTest
import PresentationExchange

@testable import SiopOpenID4VP

final class SiopOpenID4VPTests: XCTestCase {
  
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
  
  // MARK: - Validated Authorisation Request Testing
  
  func testValidatedAuthorizationRequestDataGivenValidInputData() throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validAuthorizeUrl)
    XCTAssertNotNil(authorizationRequestData)
    
    let validAuthorizationData = try? ValidatedAuthorizationRequestData(authorizationRequestData: authorizationRequestData)
    
    XCTAssertNotNil(validAuthorizationData)
  }
  
  func testValidatedAuthorizationRequestDataGivenInvalidInputData() throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.invalidAuthorizeUrl)
    let validAuthorizationData = try? ValidatedAuthorizationRequestData(authorizationRequestData: authorizationRequestData)
    
    XCTAssertNil(validAuthorizationData)
  }
  
  func testValidatedAuthorizationRequestDataGivenValidOutofScopeInput() throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validOutOfScopeAuthorizeUrl)
    XCTAssertNotNil(authorizationRequestData)
    
    do {
      _ = try ValidatedAuthorizationRequestData(authorizationRequestData: authorizationRequestData)
    } catch ValidatedAuthorizationError.unsupportedClientIdScheme(let scheme) {
      XCTAssertTrue(scheme == "redirect_uri")
      return
    }
  
    XCTAssert(false)
  }
  
  // MARK: - Resolved Validated Authorisation Request Testing
  
  func testValidationResolutionGivenDataIsValid() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validAuthorizeUrl)
    XCTAssertNotNil(authorizationRequestData)
    
    let validAuthorizationData = try? ValidatedAuthorizationRequestData(authorizationRequestData: authorizationRequestData)
    
    XCTAssertNotNil(validAuthorizationData)
    
    let resolvedValidAuthorizationData = try? await ResolvedAuthorizationRequestData(resolver: PresentationDefinitionResolver(), source: validAuthorizationData!.presentationDefinitionSource!)
    
    XCTAssertNotNil(resolvedValidAuthorizationData)
    
    let presentationDefinition = resolvedValidAuthorizationData!.presentationDefinition
    
    XCTAssert(presentationDefinition.id == "8e6ad256-bd03-4361-a742-377e8cccced0")
    XCTAssert(presentationDefinition.inputDescriptors.count == 1)
    XCTAssert(presentationDefinition.inputDescriptors.first!.constraints.fields.first!.paths.first == "$.credentialSubject.dateOfBirth")
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
  
  // MARK: - Presentation definition scopes test
  
  func testValidationResolutionGivenScopesDataIsValid() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validByScopesAuthorizeUrl)
    XCTAssertNotNil(authorizationRequestData)
    
    let validAuthorizationData = try? ValidatedAuthorizationRequestData(authorizationRequestData: authorizationRequestData)
    
    XCTAssertNotNil(validAuthorizationData)
    
    let parser = Parser()
    let result: Result<PresentationDefinitionContainer, ParserError> = parser.decode(
      path: "input_descriptors_example",
      type: "json"
    )
    
    let cachedPresentationDefinition = try? result.get().definition
    XCTAssertNotNil(cachedPresentationDefinition)
    
    let resolvedValidAuthorizationData = try? await ResolvedAuthorizationRequestData(resolver: PresentationDefinitionResolver(), source: validAuthorizationData!.presentationDefinitionSource!, predefinedDefinitions: ["com.example.input_descriptors_example": cachedPresentationDefinition!])
    
    XCTAssertNotNil(resolvedValidAuthorizationData)
    
    let presentationDefinition = resolvedValidAuthorizationData!.presentationDefinition
    
    XCTAssert(presentationDefinition.id == "32f54163-7166-48f1-93d8-ff217bdb0653")
    XCTAssert(presentationDefinition.inputDescriptors.count == 1)
    XCTAssert(presentationDefinition.inputDescriptors.first!.constraints.fields.first!.paths.first == "$.credentialSchema.id")
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
  
  func testValidationResolutionGivenReferenceDataIsValid() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? await ValidatedSiopOpenId4VPRequest(authorizationRequestData: authorizationRequestData!)
    
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
    let presentationDefinition = try await sdk.process(url: TestsConstants.validByClientByValuePresentationByReferenceUrl)
    
    XCTAssert(presentationDefinition.id == "32f54163-7166-48f1-93d8-ff217bdb0653")
    XCTAssert(presentationDefinition.inputDescriptors.count == 1)
  }
  
  func testRequestObjectGivenValidJWT() async throws {
    
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
  
  func testRequestObjectGivenValidJWTUri() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? await ValidatedSiopOpenId4VPRequest(
      requestUri: TestsConstants.passByValueJWTURI
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
  
  func testSDKValidationResolutionGivenDataRequestObjectByValueIsValid() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.requestObjectUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? await ValidatedSiopOpenId4VPRequest(
      authorizationRequestData: authorizationRequestData!
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
  
  func testSDKValidationResolutionGivenDataRequestObjectByReferenceIsValid() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.requestUriUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? await ValidatedSiopOpenId4VPRequest(
      authorizationRequestData: authorizationRequestData!
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
  
  func testSDKInstanceValidationResolutionGivenDataRequestObjectByValueIsValid() async throws {
    
    let sdk = SiopOpenID4VP()
    let presentationDefinition = try? await sdk.process(url: TestsConstants.requestObjectUrl)
    
    XCTAssertNotNil(presentationDefinition!)
    
    XCTAssert(presentationDefinition!.id == "32f54163-7166-48f1-93d8-ff217bdb0653")
    XCTAssert(presentationDefinition!.inputDescriptors.count == 2)
    XCTAssert(presentationDefinition!.inputDescriptors.first!.constraints.fields.first!.paths.first == "$.credentialSchema.id")
  }
}

private extension SiopOpenID4VPTests {
  func overrideDependencies() {
    DependencyContainer.shared.register(type: Reporting.self, dependency: {
      MockReporter()
    })
  }
}
