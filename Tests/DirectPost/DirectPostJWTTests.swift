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
import Foundation
import XCTest
import JOSESwift
import Mockingbird

@testable import SiopOpenID4VP

final class DirectPostJWTTests: DiXCTest {
  
  func testPostDirectPostJwtAuthorisationResponseGivenValidResolutionAndNegativeConsent() async throws {
    
    // Obtain an id token resolution
    let resolved: ResolvedRequestData = .idToken(
      request: .init(
        idTokenType: .attesterSigned,
        clientMetaData: Constants.testClientMetaData(),
        clientId: Constants.testClientId,
        nonce: Constants.testNonce,
        responseMode: Constants.testDirectPostJwtResponseMode,
        state: Constants.generateRandomBase64String(),
        scope: Constants.testScope
      )
    )
    
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
      request: resolved,
      holderInfo: holderInfo,
      walletConfiguration: .init(
        subjectSyntaxTypesSupported: [
          .decentralizedIdentifier,
          .jwkThumbprint
        ],
        preferredSubjectSyntaxType: .jwkThumbprint,
        decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123456789abcdefghi"),
        signingKey: try JOSEController().generatePrivateKey(),
        signingKeySet: TestsConstants.webKeySet,
        supportedClientIdSchemes: [],
        vpFormatsSupported: []
      ),
      rsaJWK: rsaJWK,
      signingKey: privateKey!,
      kid: kid
    )
    
    XCTAssert(try jose.verify(jws: jose.getJWS(compactSerialization: jws), publicKey: publicKey))
    
    // Obtain consent
    let consent: ClientConsent = .negative(message: "user_cancelled")
    
    let wallet: WalletOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123456789abcdefghi"),
      signingKey: try JOSEController().generatePrivateKey(),
      signingKeySet: TestsConstants.webKeySet,
      supportedClientIdSchemes: [],
      vpFormatsSupported: []
    )
    
    // Generate a direct post authorisation response
    let response = try? AuthorizationResponse(
      resolvedRequest: resolved,
      consent: consent,
      walletOpenId4VPConfig: wallet
    )
    
    XCTAssertNotNil(response)
    
    let service = AuthorisationService()
    let dispatcher = Dispatcher(service: service, authorizationResponse: response!)
    _ = try? await dispatcher.dispatch()
    
    XCTAssert(true)
  }
}
