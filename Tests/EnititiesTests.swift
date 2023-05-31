import XCTest
@testable import SiopOpenID4VP

class ResolvedSiopOpenId4VPRequestDataTests: XCTestCase {
  
  func testIdAndVpTokenDataInitialization() throws {
    let idTokenType: IdTokenType = .attesterSigned
    let presentationDefinition = PresentationExchange.Constants.presentationDefinitionPreview()
    let clientMetaData = try ClientMetaData(metaDataString: TestsConstants.sampleClientMetaData)
    let clientId = "testClientID"
    let nonce = "testNonce"
    let responseMode: ResponseMode = .directPost(responseURI: URL(string: "https://www.example.com")!)
    let state = "testState"
    let scope = "// Replace with an instance of `Scope`"
    
    let tokenData = ResolvedSiopOpenId4VPRequestData.IdAndVpTokenData(
      idTokenType: idTokenType,
      presentationDefinition: presentationDefinition,
      clientMetaData: clientMetaData,
      clientId: clientId,
      nonce: nonce,
      responseMode: responseMode,
      state: state,
      scope: scope
    )
    
    XCTAssertEqual(tokenData.idTokenType, idTokenType)
    XCTAssertEqual(tokenData.clientMetaData, clientMetaData)
    XCTAssertEqual(tokenData.clientId, clientId)
    XCTAssertEqual(tokenData.nonce, nonce)
    XCTAssertEqual(tokenData.state, state)
    XCTAssertEqual(tokenData.scope, scope)
  }
  
  func testIdTokenRequestInitialization() {
    let idTokenType = IdTokenType.subjectSigned
    let clientMetaDataSource: ClientMetaDataSource = .fetchByReference(url: URL(string: "https://www.example.com")!)
    let clientIdScheme: ClientIdScheme = .redirectUri
    let clientId = "dummy_client_id"
    let nonce = "dummy_nonce"
    let scope = "dummy_scope"
    let responseMode: ResponseMode = .directPost(responseURI: URL(string: "https://www.example.com")!)
    let state = "dummy_state"
    
    let request = ValidatedSiopOpenId4VPRequest.IdTokenRequest(
      idTokenType: idTokenType,
      clientMetaDataSource: clientMetaDataSource,
      clientIdScheme: clientIdScheme,
      clientId: clientId,
      nonce: nonce,
      scope: scope,
      responseMode: responseMode,
      state: state
    )
    
    XCTAssertEqual(request.idTokenType, idTokenType)
    XCTAssertEqual(request.clientIdScheme, clientIdScheme)
    XCTAssertEqual(request.clientId, clientId)
    XCTAssertEqual(request.nonce, nonce)
    XCTAssertEqual(request.scope, scope)
    XCTAssertEqual(request.state, state)
  }
}
