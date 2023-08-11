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
import JSONSchema
import Sextant
import JOSESwift

@testable import SiopOpenID4VP

final class JOSETests: DiXCTest {
  
  func testJOSEBuildTokenGivenValidRequirements() async throws {
    
    let authorizationRequestData = AuthorisationRequestObject(from: TestsConstants.validIdTokenByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? await ValidatedSiopOpenId4VPRequest(authorizationRequestData: authorizationRequestData!)
    
    XCTAssertNotNil(validatedAuthorizationRequestData)
    
    let resolvedSiopOpenId4VPRequestData = try? await ResolvedRequestData(clientMetaDataResolver: ClientMetaDataResolver(), presentationDefinitionResolver: PresentationDefinitionResolver(), validatedAuthorizationRequest: validatedAuthorizationRequestData!)
    
    XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
    
    let kid = UUID()
    let jose = JOSEController()
    
    let privateKey = try jose.generateHardcodedPrivateKey()
    let publicKey = try jose.generatePublicKey(from: privateKey!)
    let rsaJWK = try RSAPublicKey(
      publicKey: publicKey,
      additionalParameters: [
        "use": "sig",
        "kid": kid.uuidString
      ])
    
    let holderInfo: HolderInfo = .init(
      email: "email@example.com",
      name: "Bob"
    )
    
    let jws = try jose.build(
      request: resolvedSiopOpenId4VPRequestData!,
      holderInfo: holderInfo,
      walletConfiguration: .init(
        subjectSyntaxTypesSupported: [
          .decentralizedIdentifier,
          .jwkThumbprint
        ],
        preferredSubjectSyntaxType: .jwkThumbprint,
        decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123456789abcdefghi"),
        supportedClientIdSchemes: [],
        vpFormatsSupported: []
      ),
      rsaJWK: rsaJWK,
      signingKey: privateKey!,
      kid: kid
    )
    
    XCTAssert(try jose.verify(jws: jose.getJWS(compactSerialization: jws), publicKey: publicKey))
  }
}
