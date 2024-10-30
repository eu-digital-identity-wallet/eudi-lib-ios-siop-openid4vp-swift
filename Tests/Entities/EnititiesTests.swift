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

class ResolvedSiopOpenId4VPRequestDataTests: DiXCTest {
  
  func testIdAndVpTokenDataInitialization() async throws {

    overrideDependencies()
    
    let metaData = try ClientMetaData(metaDataString: TestsConstants.sampleClientMetaData)
    let validator = ClientMetaDataValidator()
    let validatedClientMetaData = try? await validator.validate(clientMetaData: metaData)
    
    let idTokenType: IdTokenType = .attesterSigned
    let presentationDefinition = PresentationExchange.Constants.presentationDefinitionPreview()
    let clientMetaData = validatedClientMetaData
    let clientId = "testClientID"
    let nonce = "testNonce"
    let responseMode: ResponseMode = .directPost(responseURI: URL(string: "https://www.example.com")!)
    let state = "testState"
    let scope = "// Replace with an instance of `Scope`"
    
    let tokenData = ResolvedRequestData.IdAndVpTokenData(
      idTokenType: idTokenType,
      presentationDefinition: presentationDefinition,
      clientMetaData: clientMetaData,
      client: .preRegistered(clientId: clientId, legalName: clientId),
      nonce: nonce,
      responseMode: responseMode,
      state: state,
      scope: scope,
      vpFormats: try! VpFormats(from: TestsConstants.testVpFormatsTO())!
    )
    
    XCTAssertEqual(tokenData.idTokenType, idTokenType)
    XCTAssertEqual(tokenData.clientMetaData, clientMetaData)
    XCTAssertEqual(tokenData.nonce, nonce)
    XCTAssertEqual(tokenData.state, state)
    XCTAssertEqual(tokenData.scope, scope)
  }
  
  func testWalletOpenId4VPConfigurationInitialization() throws {
    let subjectSyntaxTypesSupported: [SubjectSyntaxType] = [.jwkThumbprint]
    let preferredSubjectSyntaxType: SubjectSyntaxType = .jwkThumbprint
    let decentralizedIdentifier: DecentralizedIdentifier = .did("DID:example:12341512#$")
    let idTokenTTL: TimeInterval = 600.0
    let presentationDefinitionUriSupported: Bool = false
    let signingKey = try KeyController.generateRSAPrivateKey()
    let signingKeySet = WebKeySet(keys: [])
    let supportedClientIdSchemes: [SupportedClientIdScheme] = []
    let vpFormatsSupported: [ClaimFormat] = [.jwtType(.jwt)]
    let knownPresentationDefinitionsPerScope: [String: PresentationDefinition] = [:]

    let walletOpenId4VPConfiguration = SiopOpenId4VPConfiguration(
      subjectSyntaxTypesSupported: subjectSyntaxTypesSupported,
      preferredSubjectSyntaxType: preferredSubjectSyntaxType,
      decentralizedIdentifier: decentralizedIdentifier,
      idTokenTTL: idTokenTTL,
      presentationDefinitionUriSupported: presentationDefinitionUriSupported,
      signingKey: signingKey,
      signingKeySet: signingKeySet,
      supportedClientIdSchemes: supportedClientIdSchemes,
      vpFormatsSupported: vpFormatsSupported,
      knownPresentationDefinitionsPerScope: knownPresentationDefinitionsPerScope,
      jarConfiguration: .default,
      vpConfiguration: VPConfiguration.default(),
      session: SiopOpenId4VPConfiguration.walletSession
    )
    
    XCTAssertEqual(walletOpenId4VPConfiguration.subjectSyntaxTypesSupported, subjectSyntaxTypesSupported)
    XCTAssertEqual(walletOpenId4VPConfiguration.preferredSubjectSyntaxType, preferredSubjectSyntaxType)
    XCTAssertEqual(walletOpenId4VPConfiguration.decentralizedIdentifier, decentralizedIdentifier)
    XCTAssertEqual(walletOpenId4VPConfiguration.idTokenTTL, idTokenTTL)
    XCTAssertEqual(walletOpenId4VPConfiguration.presentationDefinitionUriSupported, presentationDefinitionUriSupported)
    XCTAssertEqual(walletOpenId4VPConfiguration.vpFormatsSupported, vpFormatsSupported)
  }
  
  func testSubjectSyntaxTypeInitWithThumbprint() {
    let subjectSyntaxType: SubjectSyntaxType = .jwkThumbprint
    XCTAssert(subjectSyntaxType == .jwkThumbprint)
  }

  func testSubjectSyntaxTypeInitWithDecentralizedIdentifier() {
    let subjectSyntaxType: SubjectSyntaxType = .decentralizedIdentifier
    XCTAssert(subjectSyntaxType == .decentralizedIdentifier)
  }
  
  func testValidDID() {
    let did = DecentralizedIdentifier.did("did:example:123abc")
    XCTAssertTrue(did.isValid())
  }
      
  func testInvalidDID() {
    let did = DecentralizedIdentifier.did("invalid_did")
    XCTAssertFalse(did.isValid())
  }
  
  func testEmptyDID() {
    let did = DecentralizedIdentifier.did("")
    XCTAssertFalse(did.isValid())
  }
  
  func testWhitespaceDID() {
    let did = DecentralizedIdentifier.did("  ")
    XCTAssertFalse(did.isValid())
  }
}

class VerifierFormPostTests: XCTestCase {
    
  func testUrlRequest() {
    let url = URL(string: "https://www.example.com")!
    let formData: [String: Any] = [
        "param1": "value1",
        "param2": 123,
        "param3": true
    ]
    let formPost = VerifierFormPost(url: url, formData: formData)
    
    var expectedRequest = URLRequest(url: url)
    expectedRequest.httpMethod = "POST"
    expectedRequest.httpBody = "param1=value1&param2=123&param3=true".data(using: .utf8)
    
    XCTAssertEqual(formPost.urlRequest, expectedRequest)
  }
  
  func testMethod() {
    let formPost = VerifierFormPost(url: URL(string: "https://www.example.com")!, formData: [:])
    XCTAssertEqual(formPost.method, HTTPMethod.POST)
  }
  
  func testAdditionalHeaders() {
    var formPost = VerifierFormPost(url: URL(string: "https://www.example.com")!, formData: [:])
    XCTAssertTrue(formPost.additionalHeaders.isEmpty)
    
    // Add test cases to cover other scenarios for additionalHeaders
    formPost.additionalHeaders = ["Authorization": "Bearer token"]
    XCTAssertEqual(formPost.additionalHeaders["Authorization"], "Bearer token")
  }
  
  func testBody() {
    let formData: [String: Any] = ["param": "value"]
    let formPost = VerifierFormPost(url: URL(string: "https://www.example.com")!, formData: formData)
    
    let expectedBody = "param=value".data(using: .utf8)
    XCTAssertEqual(formPost.body, expectedBody)
    
    // Add test cases to cover other scenarios for body
    let emptyFormData = [String: Any]()
    let emptyFormPost = VerifierFormPost(url: URL(string: "https://www.example.com")!, formData: emptyFormData)
    XCTAssertNotNil(emptyFormPost.body)
  }
  
  func testURLRequest() {
    let url = URL(string: "https://www.example.com")!
    let formData: [String: Any] = ["param": "value"]
    let formPost = VerifierFormPost(url: url, formData: formData)
      
    var expectedRequest = URLRequest(url: url)
    expectedRequest.httpMethod = "POST"
    expectedRequest.httpBody = "param=value".data(using: .utf8)
    
    XCTAssertEqual(formPost.urlRequest, expectedRequest)
    
    // Add test cases to cover other scenarios for urlRequest
    let request = formPost.urlRequest
    XCTAssertEqual(request.allHTTPHeaderFields, formPost.additionalHeaders)
  }
}
