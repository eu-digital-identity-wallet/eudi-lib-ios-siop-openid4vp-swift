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
import Foundation
import SwiftyJSON

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
      presentationQuery: .byPresentationDefinition(presentationDefinition),
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
      jarConfiguration: .noEncryptionOption,
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
    let emptyFormPost = VerifierFormPost(
      url: URL(string: "https://www.example.com")!,
      formData: emptyFormData
    )
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

final class VpFormatsTests: XCTestCase {
  
  func testInitWithValidValues() throws {
    let sdJwtFormat = VpFormat.sdJwtVc(
      sdJwtAlgorithms: [JWSAlgorithm(.ES256)],
      kbJwtAlgorithms: [JWSAlgorithm(.ES256)]
    )
    let jwtVpFormat = VpFormat.jwtVp(algorithms: ["RS256"])
    let ldpVpFormat = VpFormat.ldpVp(proofTypes: ["ProofType1"])
    let msoMdocFormat = VpFormat.msoMdoc(algorithms: [JWSAlgorithm(.ES256)])
    
    let vpFormats = try VpFormats(values: [sdJwtFormat, jwtVpFormat, ldpVpFormat, msoMdocFormat])
    
    XCTAssertEqual(vpFormats.values.count, 4)
    XCTAssertTrue(vpFormats.contains(sdJwtFormat))
    XCTAssertTrue(vpFormats.contains(jwtVpFormat))
    XCTAssertTrue(vpFormats.contains(ldpVpFormat))
    XCTAssertTrue(vpFormats.contains(msoMdocFormat))
  }
  
  func testInitWithDuplicateFormatsThrowsError() {
    let format = VpFormat.jwtVp(algorithms: ["RS256"])
    
    XCTAssertThrowsError(try VpFormats(values: [format, format])) { error in
      guard let validationError = error as? ValidationError else {
        return XCTFail("Unexpected error type")
      }
      XCTAssertEqual(validationError, .validationError("Multiple instances 2 found for JWT_VP."))
    }
  }
  
  
  func testFormatNames() {
    XCTAssertEqual(VpFormat.msoMdoc(algorithms: []).formatName(), .MSO_MDOC)
    XCTAssertEqual(VpFormat.sdJwtVc(sdJwtAlgorithms: [], kbJwtAlgorithms: []).formatName(), .SD_JWT_VC)
    XCTAssertEqual(VpFormat.jwtVp(algorithms: []).formatName(), .JWT_VP)
    XCTAssertEqual(VpFormat.ldpVp(proofTypes: []).formatName(), .LDP_VP)
  }
  
  func testVpFormatToJSON() {
    let format = VpFormat.sdJwtVc(
      sdJwtAlgorithms: [JWSAlgorithm(.ES256)],
      kbJwtAlgorithms: [JWSAlgorithm(.ES256)]
    )
    let json = format.toJSON()
    
    XCTAssertEqual(json["vc+sd-jwt"]["sd-jwt_alg_values"].arrayValue.map { $0.stringValue }, ["ES256"])
    XCTAssertEqual(json["vc+sd-jwt"]["kb-jwt_alg_values"].arrayValue.map { $0.stringValue }, ["ES256"])
  }
  
  func testVpFormatsToJSON() throws {
    let sdJwtFormat = VpFormat.sdJwtVc(sdJwtAlgorithms: [JWSAlgorithm(.ES256)], kbJwtAlgorithms: [JWSAlgorithm(.ES256)])
    let jwtVpFormat = VpFormat.jwtVp(algorithms: ["RS256"])
    let vpFormats = try VpFormats(values: [sdJwtFormat, jwtVpFormat])
    
    let json = vpFormats.toJSON()
    
    XCTAssertEqual(json["vp_formats"].dictionaryValue.count, 2)
  }
  
  func testVpFormatsFromJson() throws {
    let jsonString = """
    {
       "vp_formats": {
              "vc+sd-jwt": {
                  "sd-jwt_alg_values": [
                      "ES256"
                  ],
                  "kb-jwt_alg_values": [
                      "ES256"
                  ]
              },
              "mso_mdoc": {
                  "alg": [
                      "ES256"
                  ]
              }
          }
    }
    """
    
    let vpFormats = try VpFormats(jsonString: jsonString)
    
    XCTAssertEqual(vpFormats?.values.count, 2)
  }
  
  func testVpFormatEquatable() {
    let format1 = VpFormat.jwtVp(algorithms: ["RS256"])
    let format2 = VpFormat.jwtVp(algorithms: ["RS256"])
    
    XCTAssertEqual(format1, format2)
  }
  
  func testVpFormatInequality() {
    let format1 = VpFormat.jwtVp(algorithms: ["RS256"])
    let format2 = VpFormat.jwtVp(algorithms: ["ES256"])
    
    XCTAssertNotEqual(format1, format2)
  }
  
  // MARK: - Test Empty VpFormats Creation
  
  func testVpFormatsEmptyCreation() throws {
    let emptyFormats = try VpFormats.empty()
    
    XCTAssertEqual(emptyFormats.values.count, 0)
  }
  
  func testVpFormatsDefaultCreation() throws {
    let defaultFormats = try VpFormats.default()
    
    XCTAssertEqual(defaultFormats.values.count, 2)
    XCTAssertEqual(defaultFormats.values.first?.formatName(), .SD_JWT_VC)
  }
  
  func testVpFormatsInitFromTO() throws {
    let to = VpFormatsTO(
      vcSdJwt: VcSdJwtTO(sdJwtAlgorithms: ["ES256"], kdJwtAlgorithms: ["ES256"]),
      jwtVp: JwtVpTO(alg: ["RS256"]),
      ldpVp: LdpVpTO(proofType: ["ProofType"]),
      msoMdoc: MsoMdocTO(algorithms: ["ES256"])
    )
    
    let vpFormats = try VpFormats(from: to)
    
    XCTAssertEqual(vpFormats?.values.count, 4)
    XCTAssertTrue(vpFormats?.contains(.jwtVp(algorithms: ["RS256"])) ?? false)
    XCTAssertTrue(vpFormats?.contains(.msoMdoc(algorithms: [.init(.ES256)])) ?? false)
  }
  
  func testVpFormatsIntersectWithCommonElements() throws {
    let format1 = VpFormat.sdJwtVc(
      sdJwtAlgorithms: [JWSAlgorithm(.ES256)],
      kbJwtAlgorithms: [JWSAlgorithm(.ES256)]
    )
    
    let format2 = VpFormat.jwtVp(algorithms: ["RS256"])
    
    let vpFormats1 = try VpFormats(values: [format1, format2])
    let vpFormats2 = try VpFormats(values: [format1])
    
    let intersection = VpFormats.common(vpFormats1, vpFormats2)
    
    XCTAssertNotNil(intersection)
    XCTAssertEqual(intersection?.values.count, 1)
    XCTAssertTrue(intersection?.contains(format1) ?? false)
  }
  
  func testVpFormatsIntersectWithNoCommonElements() throws {
    let vpFormats1 = try VpFormats(values: [
      .sdJwtVc(sdJwtAlgorithms: [JWSAlgorithm(.ES256)], kbJwtAlgorithms: [JWSAlgorithm(.ES256)])
    ])
    
    let vpFormats2 = try VpFormats(values: [
      .jwtVp(algorithms: ["RS256"])
    ])
    
    let intersection = VpFormats.common(vpFormats1, vpFormats2)
    
    XCTAssertNil(intersection)
  }
  
  func testVpFormatsIntersectWithIdenticalFormats() throws {
    let format = VpFormat.ldpVp(proofTypes: ["ProofType1"])
    
    let vpFormats1 = try VpFormats(values: [format])
    let vpFormats2 = try VpFormats(values: [format])
    
    let intersection = VpFormats.common(vpFormats1, vpFormats2)
    
    XCTAssertNotNil(intersection)
    XCTAssertEqual(intersection?.values.count, 1)
    XCTAssertTrue(intersection?.contains(format) ?? false)
  }
  
  func testVpFormatsIntersectWithEmptySet() throws {
    let vpFormats1 = try VpFormats(values: [])
    let vpFormats2 = try VpFormats(values: [
      .jwtVp(algorithms: ["RS256"])
    ])
    
    let intersection = VpFormats.common(vpFormats1, vpFormats2)
    
    XCTAssertNil(intersection)
  }
  
  func testVpFormatsIntersectWithBothEmpty() throws {
    let vpFormats1 = try VpFormats(values: [])
    let vpFormats2 = try VpFormats(values: [])
    
    let intersection = VpFormats.common(vpFormats1, vpFormats2)
    
    XCTAssertNil(intersection)
  }
}

class WalletMetaDataTests: XCTestCase {
  
  func testWalletMetaData() throws {
    
    let walletConfiguration = try SiopOpenID4VPTests.preRegisteredWalletConfigurationWithKnownClientID()
    
    let json = walletMetaData(
      cfg: walletConfiguration
    )
    
    XCTAssertEqual(json["request_object_signing_alg_values_supported"].arrayValue.map { $0.stringValue }, ["ES256"])
    XCTAssertEqual(json["presentation_definition_uri_supported"].boolValue, true)
    XCTAssertEqual(json["vp_formats_supported"].dictionaryValue.count, 2)
    XCTAssertEqual(json["client_id_schemes_supported"].arrayValue.map { $0.stringValue }, ["pre-registered"])
    XCTAssertEqual(json["response_types_supported"].arrayValue.map { $0.stringValue }, ["vp_token", "id_token"])
    XCTAssertEqual(json["response_modes_supported"].arrayValue.map { $0.stringValue }, ["direct_post", "direct_post.jwt"])
  }
}
