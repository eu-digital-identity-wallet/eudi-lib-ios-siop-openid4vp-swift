import XCTest

@testable import openid4vp_ios

final class OpenID4VPTests: XCTestCase {
  
  // TODO: Also this info below as JSON ~> JWT ~> JWS
  // request_uri ~> url encoded url ~> 200 is a JWT
  var nonNormativeUrlString =
  "https://www.example.com/authorize?" +
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
  
  var invalidAuthorizeUrl: URL {
    let encodedUrlString = String(
      format: nonNormativeUrlString, "THIS IS NOT JSON").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed
      )!
    
    return URL(string: encodedUrlString)!
  }
  
  // MARK: - Authorisation Request Testing
  
  func testAuthorizationRequestDataGivenValidDataInURL() throws {
    let authorizationRequestData = AuthorizationRequestData(from: validAuthorizeUrl)
    XCTAssertNotNil(authorizationRequestData)
  }
  
  func testAuthorizationRequestDataGivenInvalidDataInURL() throws {
    let authorizationRequestData = AuthorizationRequestData(from: invalidAuthorizeUrl)
    XCTAssertNil(authorizationRequestData)
  }
  
  func testAuthorizationRequestDataGivenValidInput() throws {
    
    let parser = Parser()
    let authorizationResult: Result<AuthorizationRequestData, ParserError> = parser.decode(
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
    let result: Result<AuthorizationRequestData, ParserError> = parser.decode(
      path: "input_descriptors_example",
      type: "json"
    )
    
    let container = try? result.get()
    XCTAssertNotNil(container)
  }
  
  func testAuthorizationRequestDataGivenInvalidJSONInput() throws {
    let parser = Parser()
    let result: Result<AuthorizationRequestData, ParserError> = parser.decode(
      path: "i-dont-know",
      type: "json"
    )
    
    let container = try? result.get()
    XCTAssertNil(container)
  }
  
  func testValidatedAuthorizationRequestDataGivenValidInputData() throws {
    
    let authorizationRequestData = AuthorizationRequestData(from: validAuthorizeUrl)
    XCTAssertNotNil(authorizationRequestData)
    
    let validAuthorizationData = try? ValidatedAuthorizationRequestData(authorizationRequestData: authorizationRequestData)
    
    XCTAssertNotNil(validAuthorizationData)
  }
  
  func testValidatedAuthorizationRequestDataGivenInvalidInputData() throws {
    
    let authorizationRequestData = AuthorizationRequestData(from: invalidAuthorizeUrl)
    let validAuthorizationData = try? ValidatedAuthorizationRequestData(authorizationRequestData: authorizationRequestData)
    
    XCTAssertNil(validAuthorizationData)
  }
  
  func testValidatedAuthorizationRequestDataGivenValidOutofScopeInput() throws {
    
    let authorizationRequestData = AuthorizationRequestData(from: validOutOfScopeAuthorizeUrl)
    XCTAssertNotNil(authorizationRequestData)
    
    do {
      _ = try ValidatedAuthorizationRequestData(authorizationRequestData: authorizationRequestData)
    } catch ValidatedAuthorizationError.unsupportedClientIdScheme(let scheme) {
      XCTAssertTrue(scheme == "redirect_uri")
      return
    }
  
    XCTAssert(false)
  }
}
