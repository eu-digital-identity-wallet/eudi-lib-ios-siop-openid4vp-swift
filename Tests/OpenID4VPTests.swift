import XCTest

@testable import OpenID4VP

final class OpenID4VPTests: XCTestCase {
  
  // MARK: Input data
  
  var nonNormativeUrlString =
  "eudi-wallet://authorize?" +
  "response_type=vp_token" +
  "&client_id=https://client.example.org/" +
  "&client_id_scheme=pre-registered" +
  "&redirect_uri=https://client.example.org/" +
  "&presentation_definition=%@" +
  "&nonce=n-0S6_WzA2Mj"
  
  var nonNormativeOutOfScopeUrlString =
  "https://www.example.com/authorize?" +
  "response_type=vp_token" +
  "&client_id=https://client.example.org/" +
  "&client_id_scheme=redirect_uri" +
  "&redirect_uri=https://client.example.org/" +
  "&presentation_definition=%@" +
  "&nonce=n-0S6_WzA2Mj"
  
  var nonNormativeByReferenceUrlString =
  "eudi-wallet://authorize?" +
  "response_type=vp_token" +
  "&client_id=https://client.example.org/" +
  "&client_id_scheme=pre-registered" +
  "&redirect_uri=https://client.example.org/" +
  "&presentation_definition_uri=%@" +
  "&nonce=n-0S6_WzA2Mj"
  
  var nonNormativeScopesUrlString =
  "https://www.example.com/authorize?" +
  "response_type=vp_token" +
  "&client_id=https://client.example.org/" +
  "&client_id_scheme=pre-registered" +
  "&redirect_uri=https://client.example.org/" +
  "&scope=%@" +
  "&nonce=n-0S6_WzA2Mj"
  
  var validOutOfScopeAuthorizeUrl: URL {
    // TODO: use definitition, not container
    let presentationDefinitionJson = try! String(
      contentsOf: Bundle.module.url(forResource: "minimal_example", withExtension: "json")!
    )
    
    let encodedUrlString = String(
      format: nonNormativeOutOfScopeUrlString,
      presentationDefinitionJson).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed
      )!
    
    return URL(string: encodedUrlString)!
  }
  
  var validAuthorizeUrl: URL {
    let presentationDefinitionJson = try! String(
      contentsOf: Bundle.module.url(forResource: "minimal_example", withExtension: "json")!
    )
    
    let encodedUrlString = String(
      format: nonNormativeUrlString,
      presentationDefinitionJson).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed
      )!
    
    return URL(string: encodedUrlString)!
  }
  
  var validMatchAuthorizeUrl: URL {
    let presentationDefinitionJson = try! String(
      contentsOf: Bundle.module.url(forResource: "basic_example", withExtension: "json")!
    )
    
    let encodedUrlString = String(
      format: nonNormativeUrlString,
      presentationDefinitionJson).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed
      )!
    
    return URL(string: encodedUrlString)!
  }
  
  var validByReferenceAuthorizeUrl: URL {
    let urlString = String(
      format: nonNormativeByReferenceUrlString,
      "https://us-central1-dx4b-4c2d8.cloudfunctions.net/api_ecommbx/presentation_definition/32f54163-7166-48f1-93d8-ff217bdb0653"
    )
    
    return URL(string: urlString)!
  }
  
  var validByScopesAuthorizeUrl: URL {
    let urlString = String(
      format: nonNormativeScopesUrlString,
      "com.example.input_descriptors_example"
    )
    
    return URL(string: urlString)!
  }
  
  var invalidAuthorizeUrl: URL {
    let encodedUrlString = String(
      format: nonNormativeUrlString, "THIS IS NOT JSON").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed
      )!
    
    return URL(string: encodedUrlString)!
  }
  
  // MARK: - Authorisation Request Testing
  
  func testAuthorizationRequestDataGivenValidDataInURL() throws {
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: validAuthorizeUrl)
    XCTAssertNotNil(authorizationRequestData)
  }
  
  func testAuthorizationRequestDataGivenValidInput() throws {
    
    let parser = Parser()
    let authorizationResult: Result<AuthorizationRequestUnprocessedData, ParserError> = parser.decode(
      path: "valid_authorizaton_data_example",
      type: "json"
    )
    
    let authorization = try? authorizationResult.get()
    guard
      let authorization = authorization
    else {
      XCTAssert(false)
      return
    }
    
    let definitionContainerResult: Result<PresentationDefinitionContainer, ParserError> = parser.decode(json: authorization.presentationDefinition!)
    let definitionContainer = try? definitionContainerResult.get()
    guard
      let definitionContainer = definitionContainer
    else {
      XCTAssert(false)
      return
    }
    
    XCTAssert(definitionContainer.definition.inputDescriptors.count == 1)
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
  
  func testAuthorizationRequestDataGivenInvalidJSONInput() throws {
    let parser = Parser()
    let result: Result<AuthorizationRequestUnprocessedData, ParserError> = parser.decode(
      path: "i-dont-know",
      type: "json"
    )
    
    let container = try? result.get()
    XCTAssertNil(container)
  }
  
  // MARK: - Validated Authorisation Request Testing
  
  func testValidatedAuthorizationRequestDataGivenValidInputData() throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: validAuthorizeUrl)
    XCTAssertNotNil(authorizationRequestData)
    
    let validAuthorizationData = try? ValidatedAuthorizationRequestData(authorizationRequestData: authorizationRequestData)
    
    XCTAssertNotNil(validAuthorizationData)
  }
  
  func testValidatedAuthorizationRequestDataGivenInvalidInputData() throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: invalidAuthorizeUrl)
    let validAuthorizationData = try? ValidatedAuthorizationRequestData(authorizationRequestData: authorizationRequestData)
    
    XCTAssertNil(validAuthorizationData)
  }
  
  func testValidatedAuthorizationRequestDataGivenValidOutofScopeInput() throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: validOutOfScopeAuthorizeUrl)
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
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: validAuthorizeUrl)
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
    
    let sdk = OpenID4VP()
    let presentationDefinition = try await sdk.process(url: validAuthorizeUrl)
    
    XCTAssert(presentationDefinition.id == "8e6ad256-bd03-4361-a742-377e8cccced0")
    XCTAssert(presentationDefinition.inputDescriptors.count == 1)
  }
  
  func testSDKValidationResolutionGivenDataByReferenceIsValid() async throws {
    
    let sdk = OpenID4VP()
    let presentationDefinition = try await sdk.process(url: validByReferenceAuthorizeUrl)
    
    XCTAssert(presentationDefinition.id == "32f54163-7166-48f1-93d8-ff217bdb0653")
    XCTAssert(presentationDefinition.inputDescriptors.count == 1)
  }
  
  func testSDKValidationResolutionGivenDataIsInvalid() async throws {
    
    let sdk = OpenID4VP()
    
    do {
      _ = try await sdk.process(url: invalidAuthorizeUrl)
    } catch {
      XCTAssert(true, error.localizedDescription)
      return
    }
    
    XCTAssert(false)
  }
  
  // MARK: - Presentation definition scopes test
  
  func testValidationResolutionGivenScopesDataIsValid() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: validByScopesAuthorizeUrl)
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
    
    let sdk = OpenID4VP()
    let passportClaim = Claim(
      id: "samplePassport",
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
    
    let presentationDefinition = try await sdk.process(url: validAuthorizeUrl)
    let match = sdk.match(presentationDefinition: presentationDefinition, claims: [passportClaim])
    
    XCTAssert(presentationDefinition.id == "8e6ad256-bd03-4361-a742-377e8cccced0")
    XCTAssert(presentationDefinition.inputDescriptors.count == 1)
    
    if case .notFound = match {
      XCTAssert(true)
      
    } else {
      XCTFail("wrong match")
    }
  }
}
